# 📦 XML Parsing Benchmark Suite

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-linux-lightgrey)
![Status](https://img.shields.io/badge/status-active-brightgreen)

> Benchmarking XML parsing performance across multiple languages and libraries.

---

## ✨ Overview

This project benchmarks **streaming** and **tree-based** XML parsers in various languages, measuring:

- ✅ Execution time (`real`, `user`, `sys`)
- 📉 Peak memory usage (in kilobytes)
- ⚙️ Parsing method (DOM, SAX, StAX, etc.)

The suite helps answer:  
**“Which language/library is fastest and most memory-efficient for parsing large XML files?”**

---

## 🏁 Quick Start

### 🔧 Recommended Flow

The easiest way to run everything:

```bash
make install && make full
```

This will:

1. Install all environments and dependencies (via [`mise`](https://github.com/jdx/mise))
2. Generate XML data
3. Build all implementations
4. Run benchmarks
5. Visualize results

---

## 📦 Installation

> ℹ️ **Note:** `mise` is a convenient runtime manager. You can also set up environments manually if you prefer.

### 1. Install System Dependencies

```bash
sudo apt update
sudo apt install -y autoconf bison re2c libxml2-dev libsqlite3-dev \
  libcurl4-openssl-dev libjpeg-dev libpng-dev libonig-dev libssl-dev \
  libreadline-dev libzip-dev libtidy-dev libxslt-dev pkg-config \
  build-essential locate libgd-dev libglib2.0-dev uthash-dev
```

### 2. Install Languages via `mise`

```bash
make install
```

---

## 📈 Benchmark Results

### 🏎️ Top 5 Fastest (by `real` time)

| 🥇 Rank | Language | Implementation    | ⏱ Real (s) | 🧠 Mem (KB) |
|--------:|----------|-------------------|------------|-------------|
| 1       | C++      | pugixml           | **0.37**   | 505224      |
| 2       | C        | expat             | 0.81       | **3780**     |
| 3       | C++      | expat             | 0.81       | 5736        |
| 4       | Java     | sax               | 1.18       | 567188      |
| 5       | Java     | stax              | 1.21       | 568476      |

### 💾 Top 5 Most Memory-Efficient

| 🥇 Rank | Language | Implementation | 📉 Mem (KB) | ⏱ Real (s) |
|--------:|----------|----------------|-------------|------------|
| 1       | C        | expat          | **3780**     | 0.81       |
| 2       | C++      | expat          | 5736        | 0.81       |
| 3       | Go       | xml-stream     | 11920       | 1.61       |
| 4       | Ruby     | ox-sax         | 17260       | 1.45       |
| 5       | Python   | lxml-iterparse | 24988       | 2.79       |

> 📊 Full benchmark table is viewable via `make visualize`.

---

## 🔍 Usage

```bash
make generate MB=100  # Generate sample XML data
make build            # Build all implementations
make bench            # Run all benchmarks
make visualize        # Show formatted result table
make clean            # Cleans all compiled and temporary files
```

To benchmark a single language:

```bash
make bench-ruby
make bench-c
...
```

---

## 🗂 Project Structure

```
.
├── data/                  # Generated XML and benchmark results
├── docs/
│   ├── benchmark_table.md
│   ├── sample.xml         # Simple file with single order, customer etc.
├── langs/                 # Implementations by language
│   ├── cpp/
│   ├── ruby/
│   └── ...
├── tools/                 # Utility scripts
│   ├── generate_xml.rb
│   └── visualize_bench.rb
├── Makefile               # Benchmark automation
└── README.md
```

---

## 🤝 Contributing

Contributions are more than welcome!

In particular, feel free to:
- 🔧 Improve or optimize existing parsers (as long as it doesn't break fairness)
- 🆕 Add parsers for new languages or libraries
- 🛠 Refactor internal tooling or Makefiles

**Note:** Please avoid "extreme" tuning (e.g. hardcoding output, unrealistic environment hacks) — the goal is realistic, portable performance.

Want to add a new parser?

1. Add your code under `langs/<language>/<parser_name>/`
2. Implement `build`, `run`, and `clean` in the parser's `Makefile`
3. Update `VARIANTS_<language>` in the root `Makefile`
4. Test it:

```bash
make build-<language>
make bench-<language>
make visualize          # Validates outputs
```

5. Open a PR 🙌

---

## 🧪 Methodology

- By default, a synthetic XML file of **100 MB** is generated for all parsers using `tools/generate_xml.rb`.  
  A small example is included in [`docs/sample.xml`](docs/sample.xml) for reference.
- Parsers aim to disable or avoid **multithreading**, garbage collection tuning, or aggressive JIT tricks where possible.
- All tests are run in isolation, and measurements include:
  - `real` (wall time),
  - `user` (CPU time),
  - `sys` (system calls),
  - and `mem` (peak memory usage in KB).
- Benchmarks were executed on a **Ryzen 7 5800X**, running Ubuntu 24.04.

> 📄 Full benchmark results are available in [`docs/benchmark_table.md`](docs/benchmark_table.md)

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

## 🙏 Acknowledgments

Made with ❤️, `make`, and a lot of XML frustration.
---

## 🗣️ Supported Languages & Parsers

- **Ruby**: `ox`, `ox-sax`, `nokogiri`
- **Python**: `lxml`, `lxml-iterparse`, `elementtree`
- **Go**: `encoding/xml`, `xml-stream-parser`, `mxj`
- **JavaScript**: `fast-xml-parser`, `sax`
- **.NET**: `XmlDocument`, `XDocument`, `XmlReader`
- **Java**: `DOM`, `SAX`, `StAX`
- **PHP**: `DOMDocument`, `XMLReader`
- **C**: `libxml2`, `Expat`
- **C++**: `pugixml`, `Expat`