async function main() {
    // Initialize xterm.js (loaded globally)
    const term = new window.Terminal({
        cursorBlink: true,
        fontFamily: 'Menlo, Monaco, "Courier New", monospace',
        fontSize: 16,
        theme: {
            background: '#000000',
            foreground: '#ffffff',
        }
    });

    const fitAddon = new window.FitAddon.FitAddon();
    term.loadAddon(fitAddon);
    term.open(document.getElementById('terminal'));
    fitAddon.fit();

    window.addEventListener('resize', () => fitAddon.fit());

    term.write('Loading Ruby WASM...\r\n');

    // The UMD bundle exposes the module as window["ruby-wasm-wasi"]
    const RubyWasmModule = window["ruby-wasm-wasi"];
    const { DefaultRubyVM } = RubyWasmModule;

    // Fetch and compile the WASM module (using 3.4 Ruby)
    const response = await fetch("https://cdn.jsdelivr.net/npm/@ruby/3.4-wasm-wasi@2.7.2/dist/ruby+stdlib.wasm");
    const buffer = await response.arrayBuffer();
    const wasmModule = await WebAssembly.compile(buffer);

    // Pass the compiled WebAssembly.Module to DefaultRubyVM
    const { vm } = await DefaultRubyVM(wasmModule);

    term.write('Ruby loaded. Loading application files...\r\n');

    // Prepare virtual filesystem (only Ruby files, not large data files)
    const appFiles = [
        'lib/anagram_trainer/game.rb',
        'lib/anagram_trainer/ui.rb',
        'lib/anagram_trainer/dictionary.rb',
        'lib/anagram_trainer/store.rb',
        'lib/anagram_trainer/trainer.rb'
    ];

    // Large data files will be fetched via HTTP when needed
    const dataFiles = [
        'data/dictionary.txt',
        'data/suffix_words.txt',
        'data/prefix_words.txt'
    ];

    // Load Ruby files into WASM filesystem (small files only)
    for (const file of appFiles) {
        try {
            const fileRes = await fetch(`../${file}`);
            if (!fileRes.ok) throw new Error(`Failed to load ${file}`);
            const content = await fileRes.text();

            // Use Ruby to create directories and write files
            const parts = file.split('/');
            const dirs = parts.slice(0, -1);

            // Create directory structure
            let path = '';
            for (const dir of dirs) {
                path = path ? `${path}/${dir}` : dir;
                await vm.evalAsync(`require 'fileutils'; FileUtils.mkdir_p('${path}')`);
            }

            // Write file using evalAsync
            const escapedFile = file.replace(/'/g, "\\'");
            const base64Content = btoa(unescape(encodeURIComponent(content)));
            await vm.evalAsync(`
                require 'base64'
                File.write('${escapedFile}', Base64.decode64('${base64Content}'))
            `);

            term.write(`  ✓ ${file}\r\n`);
        } catch (e) {
            term.write(`  ✗ ${file}: ${e.message}\r\n`);
            console.error(e);
        }
    }

    // Create data directory and stub files for large data files
    // Ruby will fetch them via HTTP when needed
    await vm.evalAsync(`require 'fileutils'; FileUtils.mkdir_p('data')`);
    term.write(`  Created data directory (files will load on-demand)\r\n`);

    term.write('Starting application...\r\n\r\n');

    // Setup async input handling
    let inputBuffer = [];
    let inputResolver = null;

    term.onData(data => {
        if (inputResolver) {
            // If Ruby is waiting for input, resolve immediately
            const resolve = inputResolver;
            inputResolver = null;
            resolve(data);
        } else {
            // Buffer the input
            inputBuffer.push(data);
        }
    });

    // Add write queue for flow control
    let writeQueue = [];
    let isWriting = false;

    async function processWriteQueue() {
        if (isWriting || writeQueue.length === 0) return;
        isWriting = true;

        while (writeQueue.length > 0) {
            const data = writeQueue.shift();
            await new Promise(resolve => {
                term.write(data, resolve);
            });
        }

        isWriting = false;
    }

    // Expose terminal and input function to Ruby
    window.terminal = {
        write: (data) => {
            writeQueue.push(data);
            processWriteQueue();
        },
        clear: () => term.clear()
    };

    window.getInput = async function() {
        if (inputBuffer.length > 0) {
            return inputBuffer.shift();
        }
        return await new Promise(resolve => {
            inputResolver = resolve;
        });
    };

    try {
        // Run the application with terminal UI override (using evalAsync for await support)
        await vm.evalAsync(`
            $LOAD_PATH << 'lib'
            require 'js'
            require 'anagram_trainer/game'

            # Override File methods for data files to fetch via HTTP
            JS.global[:console].call(:log, "Setting up File method overrides for data files...")

            class << File
              alias_method :original_read, :read
              alias_method :original_readlines, :readlines
              alias_method :original_exist?, :exist?

              def read(path, *args)
                # If it's a data file, fetch via HTTP from web/data directory
                if path.to_s.include?('data/')
                  # Extract just the filename and fetch from web/data
                  filename = File.basename(path)
                  url = "data/\#{filename}"
                  JS.global[:console].call(:log, "Fetching \#{url} via HTTP (read)...")
                  response = JS.global.fetch(url).await
                  text = response.call(:text).await
                  return text.to_s
                end
                original_read(path, *args)
              end

              def readlines(path, *args)
                # If it's a data file, fetch via HTTP from web/data directory
                if path.to_s.include?('data/')
                  # Extract just the filename and fetch from web/data
                  filename = File.basename(path)
                  url = "data/\#{filename}"
                  JS.global[:console].call(:log, "Fetching \#{url} via HTTP (readlines)...")
                  response = JS.global.fetch(url).await
                  text = response.call(:text).await
                  return text.to_s.lines
                end
                original_readlines(path, *args)
              end

              def exist?(path)
                # Data files are always available via HTTP
                if path.to_s.include?('data/')
                  return true
                end
                original_exist?(path)
              end
            end

            # Override UI for WASM/xterm integration
            JS.global[:console].call(:log, "Setting up UI overrides...")

            module AnagramTrainer
              class UI
                def self.clear_screen
                  JS.global[:console].call(:log, "UI.clear_screen called")
                  JS.global[:terminal].call(:clear)
                  JS.global[:console].call(:log, "UI.clear_screen done")
                end

                def self.print(msg)
                  JS.global[:console].call(:log, "UI.print called with: ", msg.to_s[0..50])
                  JS.global[:terminal].call(:write, msg.to_s.gsub("\\n", "\\r\\n"))
                  JS.global[:console].call(:log, "UI.print done")
                end

                def self.puts(msg = "")
                  JS.global[:console].call(:log, "UI.puts called")
                  print(msg.to_s + "\\n")
                  JS.global[:console].call(:log, "UI.puts done")
                end

                def self.gets(prompt = "")
                  print(prompt) if prompt && !prompt.empty?
                  line = ""
                  loop do
                    char = JS.global.call(:getInput).await.to_s

                    # Handle backspace
                    if char == "\\x7f" || char == "\\b"
                      if line.length > 0
                        line = line[0...-1]
                        @@js_terminal.call(:write, "\\b \\b")
                      end
                      next
                    end

                    # Handle enter
                    if char == "\\r" || char == "\\n"
                      @@js_terminal.call(:write, "\\r\\n")
                      break
                    end

                    # Regular character
                    line += char
                    @@js_terminal.call(:write, char)
                  end
                  line
                end

                def self.read_key
                  JS.global[:console].call(:log, "UI.read_key called, waiting for input...")
                  # Call getInput via JS.global and await the promise
                  char = JS.global.call(:getInput).await.to_s
                  JS.global[:console].call(:log, "UI.read_key got char: ", char.inspect)

                  # Handle escape sequences for arrow keys
                  if char == "\\e"
                    # In xterm, arrow keys are sent as escape sequences
                    return :esc
                  end

                  # xterm sends arrow keys as special sequences
                  case char
                  when "\\e[A" then :up
                  when "\\e[B" then :down
                  when "\\e[C" then :right
                  when "\\e[D" then :left
                  else char
                  end
                end

                def self.get_char
                  # Call getInput via JS.global and await the promise
                  char = JS.global.call(:getInput).await.to_s
                  char
                end

                # ANSI color codes still work in xterm
                def self.colorize(text, color_code)
                  "\\e[\#{color_code}m\#{text}\\e[0m"
                end

                def self.dim(text)
                  colorize(text, 2)
                end

                def self.flash
                  # Terminal bell
                  JS.global[:terminal].call(:write, "\\x07")
                end

                def self.green(text)
                  colorize(text, 32)
                end

                def self.red(text)
                  colorize(text, 31)
                end

                def self.yellow(text)
                  colorize(text, 33)
                end

                def self.cyan(text)
                  colorize(text, 36)
                end

                def self.bold(text)
                  colorize(text, 1)
                end

                def self.feedback(guess, target)
                  output = ""
                  guess.chars.each_with_index do |char, index|
                    output += if target[index] == char
                      green(char)
                    else
                      char
                    end
                  end
                  output
                end
              end
            end

            # Start the game
            JS.global[:console].call(:log, "Creating game instance...")
            game = AnagramTrainer::Game.new('.')
            JS.global[:console].call(:log, "Game created, about to call start...")

            # Monkey patch to add debugging
            class AnagramTrainer::Game
              alias_method :original_start, :start

              def start
                JS.global[:console].call(:log, "Inside Game#start, about to clear screen...")
                original_start
                JS.global[:console].call(:log, "Game#start finished")
              end
            end

            game.start
            JS.global[:console].call(:log, "Game finished")
        `);
    } catch (error) {
        term.write(`\\r\\n\\r\\nError: ${error.message}\\r\\n`);
        console.error(error);
    }
}

main();
