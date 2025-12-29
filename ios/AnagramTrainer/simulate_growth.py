import argparse
import matplotlib.pyplot as plt

def simulate_compression():
    # Constants matching the Swift implementation proposal
    # Based on radii: Submit Outer ~210, Submit Inner ~130 -> 80 thickness
    # Clear Outer ~125, Clear Inner ~45 -> 80 thickness
    # Gap ~5
    
    start_thickness = 80.0
    end_thickness = 10.0
    
    start_gap = 5.0
    end_gap = 1.0
    
    # Outer boundary fixed
    r_submit_outer = 210.0
    
    steps = 100
    progress_values = [i / steps for i in range(steps + 1)]
    
    thickness_values = []
    gap_values = []
    
    r_submit_inners = []
    r_clear_outers = []
    r_clear_inners = []
    r_skip_values = []
    
    print(f"{'Progress':<10} | {'Thickness':<10} | {'Gap':<10} | {'Skip Radius':<10}")
    print("-" * 50)
    
    for p in progress_values:
        # Linear interpolation
        current_thickness = start_thickness + (end_thickness - start_thickness) * p
        current_gap = start_gap + (end_gap - start_gap) * p
        
        # Calculate Radii from Outside In
        r_submit_inner = r_submit_outer - current_thickness
        r_clear_outer = r_submit_inner - current_gap
        r_clear_inner = r_clear_outer - current_thickness
        r_skip = r_clear_inner
        
        thickness_values.append(current_thickness)
        gap_values.append(current_gap)
        
        r_submit_inners.append(r_submit_inner)
        r_clear_outers.append(r_clear_outer)
        r_clear_inners.append(r_clear_inner)
        r_skip_values.append(r_skip)
        
        if int(p * 100) % 10 == 0:
             print(f"{p:<10.2f} | {current_thickness:<10.2f} | {current_gap:<10.2f} | {r_skip:<10.2f}")

    # Plotting
    plt.figure(figsize=(10, 6))
    
    plt.plot(progress_values, thickness_values, label='Ring Thickness', linewidth=2)
    plt.plot(progress_values, r_skip_values, label='Skip Button Radius', linewidth=2, linestyle='--')
    
    plt.title('Button Compression Simulation')
    plt.xlabel('Hold Progress (0.0 to 1.0)')
    plt.ylabel('Points (pt)')
    plt.grid(True, alpha=0.3)
    plt.legend()
    
    plt.savefig('compression_graph.png')
    print("\nGraph saved to compression_graph.png")

if __name__ == "__main__":
    simulate_compression()
