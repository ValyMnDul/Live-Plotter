
# Live Plotter


![LivePlotter](GIF)

**Live Plotter** allows users to upload custom **CSV** files and watch their data get rendered dynamically as a rolling time-series chart.

## How to use



## CSV File Format

To ensure smooth parsing, make sure your CSV file follows this simple structure:

- Format: `.csv`
- Columns:
    - Column 1: **X** value
    - Column 2: **Y** value
- Header: The first row is treated as a header and skipped automatically.

### Example CSV

```csv
time,value
0.0, 1.25
0.1, 1.80
0.2, 2.10
0.3, 0.45
0.4, -1.15
```

## Build With

- **[Flutter](https://fluter.dev/) & [Dart](https://dart.dev/)** => Cross-platform UI
- **[syncfusion_flutter_charts](https://pub.dev/packages/syncfusion_flutter_charts)** => High-performance chart rendering
- **[file_selector](https://pub.dev/packages/file_selector)** => Cross-platform native dialogs for selecting local CSV files.
- **[csv](https://pub.dev/packages/csv)** => Fast CSV parsing library

## Contribution

Feel free to open an issue or submit a Pull Request if you have ideas for new features or optimizations!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.