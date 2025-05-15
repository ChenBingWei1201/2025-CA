import os
import argparse
import matplotlib.pyplot as plt

# Set up argument parsing
parser = argparse.ArgumentParser(description='Plot graph from CSV file.')
parser.add_argument('--name', required=True, help='CSV file name', default='l1i_size.csv')
parser.add_argument('--row', required=True, help='Row name to extract data', default='L1-I size')
parser.add_argument('--xlabel', required=True, help='X-axis label', default='Size (Bytes)')
parser.add_argument('--ylabel', required=True, help='Y-axis label', default='Latency (ms)')
parser.add_argument('--title', required=True, help='Graph title', default='Merge Sort Performance w/ L1-I$ size Config')
parser.add_argument('--output_name', required=True, help='Output image file name', default='l1i_size.png')
parser.add_argument('--ylimit', required=True, help='Y-axis limit', default=2.5)
args = parser.parse_args()

# Get the absolute path of the CSV file
file_name = 'part1/' + args.name  # Update with your actual file name
file_path = os.path.abspath(file_name)
output_dir = os.path.abspath('img')

try:
    # Manually read the CSV file line by line and extract relevant data
    simulated_time = []
    size = []

    # Open the file and parse lines manually
    with open(file_path, 'r', encoding='utf-8-sig') as file:
        lines = file.readlines()

    # Extract simulated time and L1-D size from the relevant lines
    for line in lines:
        # Split the line by commas and remove any leading/trailing whitespace
        data = line.strip().split(',')

        # Check for the specific keywords and extract the data
        if data[0] == 'simulated time':
            simulated_time = [float(value) * 1000 for value in data[1:]]  # Convert seconds to milliseconds
        elif data[0] == args.row:
            size = [int(value) for value in data[1:]]

    # Plot the line graph
    plt.figure(figsize=(8, 5))
    plt.plot(size, simulated_time, marker='o', linestyle='-', color='blue', label='Simulated Time')
    for x, y in zip(size, simulated_time):
        plt.text(x, y, f'{y:.4f}', ha='left', va='bottom', fontsize=9, color='black')

    plt.xlabel(args.xlabel)
    plt.ylabel(args.ylabel)
    plt.title(args.title)
    plt.xscale('log')
    plt.ylim(0, float(args.ylimit))
    plt.xticks(size, size)
    plt.grid(True, which='both', linestyle='--', linewidth=0.5)
    plt.legend()

    output_path = os.path.join(output_dir, args.output_name)
    plt.savefig(output_path)
    plt.close()

except FileNotFoundError:
    print(f"Error: The file '{file_name}' was not found at '{file_path}'. Please check the file path.")
except Exception as e:
    print(f"An unexpected error occurred: {e}")

