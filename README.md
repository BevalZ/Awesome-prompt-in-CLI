# Awesome Prompts for Academic Work

A comprehensive collection of AI prompts specifically designed for academic research, writing, and analysis across multiple disciplines. This repository provides structured, high-quality prompts to enhance productivity in academic workflows.

## 🎭 Choose Your Path

<table>
<tr>
<td width="25%">

### 🆕 **New User**
**Just getting started?**

➤ [Overview](#-overview)  
➤ [Getting Started](#-getting-started)  
➤ [Try a Search](#2-search-existing-prompts)  
➤ [Add First Prompt](#1-add-new-prompts)

</td>
<td width="25%">

### 🔍 **Prompt Hunter**
**Looking for existing prompts?**

➤ [Search Tool](#2-search-existing-prompts)  
➤ [Browse Categories](#-categories-overview)  
➤ [Quick Search](#most-common-tasks-click-to-expand)  
➤ [Other Languages](#-comprehensive-multilingual-support)

</td>
<td width="25%">

### ✍️ **Content Creator**
**Want to add prompts?**

➤ [Add Tool](#1-add-new-prompts)  
➤ [Prompt Format](#-prompt-format)  
➤ [Formatting Guide](#-prompt-formatting-guidelines)  
➤ [Contributing](#-contributing)

</td>
<td width="25%">

### 🛠️ **Power User**  
**Need advanced features?**

➤ [All Tools](#-tools-reference)  
➤ [CLI Reference](#-tools-reference)  
➤ [Translation Tools](#4-translation-tools)  
➤ [Category Management](#3-manage-categories)

</td>
</tr>
</table>

## 📋 Table of Contents

### 🚀 Quick Start
- [Overview](#-overview) 
- [Quick Start](#-quick-start)
- [Getting Started](#-getting-started)

### 🛠️ Tools & Usage
- [CLI Tools](#using-the-cli-tools)
  - [Add Prompts](#1-add-new-prompts) | [Search](#2-search-existing-prompts) | [Manage Categories](#3-manage-categories) | [Translations](#4-translation-tools)
- [Tools Reference](#-tools-reference)
- [Usage Examples](#usage-examples)

### 📚 Documentation & Help
- [📋 Most Common Tasks](#most-common-tasks-click-to-expand) - Quick command reference
- [🛠️ Features Overview](#-features) - Tool capabilities summary
- [📁 Repository Structure](#-repository-structure) - Project organization
- [📝 Prompt Format](#-prompt-format) - Basic format guide
- [📖 Detailed Tool Docs](#-detailed-tool-documentation) - Complete tool reference
- [📋 Formatting Guidelines](#-prompt-formatting-guidelines) - Comprehensive style guide
- [❓ Support & Help](#-support) - Get assistance

### 🌍 Languages & Categories
- [Multilingual Support](#-comprehensive-multilingual-support)
- [Categories Overview](#-categories-overview)

### 🤝 Project Info
- [Contributing](#-contributing)
- [License](#-license)
- [Support](#-support)

---

## ⚡ Quick Navigation

**New User?** → [Overview](#-overview) → [Getting Started](#-getting-started) → [Add Your First Prompt](#1-add-new-prompts)

**Need Help?** → [Tools Reference](#-tools-reference) → [Usage Examples](#usage-examples) → [Support](#-support)

**Looking for Prompts?** → [Search Tool](#2-search-existing-prompts) → [Categories](#-categories-overview) → [Browse by Language](#-comprehensive-multilingual-support)

**Want to Contribute?** → [Prompt Format](#-prompt-format) → [Adding Prompts](#1-add-new-prompts) → [Contributing Guide](#-contributing)

---

## 🎯 Overview

This collection includes prompts for academic research across 12 major academic languages:
- **🇺🇸 English (EN)** - Complete collection
- **🇯🇵 Japanese (JP)** - Complete collection  
- **🇨🇳 Chinese (ZH)** - Complete collection
- **🇩🇪 German (DE)** - Complete collection
- **🇫🇷 French (FR)** - Complete collection
- **🇪🇸 Spanish (ES)** - Complete collection
- **🇮🇹 Italian (IT)** - Complete collection
- **🇵🇹 Portuguese (PT)** - Complete collection
- **🇷🇺 Russian (RU)** - Complete collection
- **🇸🇦 Arabic (AR)** - Complete collection
- **🇰🇷 Korean (KO)** - Complete collection
- **🇮🇳 Hindi (HI)** - Complete collection

### Academic Disciplines:
- **Computer Science**: Machine Learning, AI, Software Engineering, Data Science
- **Natural Sciences**: Physics, Chemistry, Biology, Environmental Science
- **Engineering**: Mechanical, Electrical, Civil, Biomedical Engineering
- **Medical Sciences**: Clinical Research, Public Health, Biomedical Research
- **Social Sciences**: Psychology, Sociology, Political Science, Economics
- **Humanities**: Literature, Philosophy, History, Cultural Studies
- **Mathematics & Statistics**: Pure Math, Applied Math, Statistical Analysis
- **Business & Management**: Strategy, Marketing, Finance, Operations
- **General Academic**: Interdisciplinary, Academic Writing, Research Methods

## 🚀 Quick Start

## 🌐 Cross-Platform Support

This toolkit is designed to work seamlessly across all major operating systems:

### ✅ Supported Platforms

| Platform | Environment | Launch Command |
|----------|-------------|----------------|
| **Windows** | CMD | `main.bat` |
| **Windows** | PowerShell | `.\main.ps1` |
| **Windows** | Git Bash | `bash main.sh` |
| **Windows** | WSL (Ubuntu/Debian) | `bash main.sh` |
| **Windows** | Cygwin | `bash main.sh` |
| **Linux** | bash/zsh/sh | `bash main.sh` |
| **macOS** | bash/zsh | `bash main.sh` |

### 🔧 Features

- **Automatic OS Detection**: Scripts detect your operating system automatically
- **Path Conversion**: Windows paths are automatically converted when needed
- **Native Launchers**: Use `main.bat` (CMD) or `main.ps1` (PowerShell) on Windows
- **No Dependencies**: Pure Bash implementation, no external tools required
- **Colored Output**: Terminal colors work across all platforms

### 🚀 Quick Start by Platform

<details>
<summary><strong>Windows Users (Click to expand)</strong></summary>

#### Option 1: CMD (Recommended for Windows)
```cmd
cd path\to\Awesome-prompt-in-CLI
main.bat
```

#### Option 2: PowerShell
```powershell
cd path\to\Awesome-prompt-in-CLI
.\main.ps1
```

#### Option 3: Git Bash
```bash
cd /d/path/to/Awesome-prompt-in-CLI
bash main.sh
```

#### Option 4: WSL (Windows Subsystem for Linux)
```bash
cd /mnt/d/path/to/Awesome-prompt-in-CLI
bash main.sh
```

</details>

<details>
<summary><strong>Linux Users (Click to expand)</strong></summary>

```bash
cd ~/path/to/Awesome-prompt-in-CLI
bash main.sh
# Or make it executable and run directly:
chmod +x main.sh
./main.sh
```

</details>

<details>
<summary><strong>macOS Users (Click to expand)</strong></summary>

```bash
cd ~/path/to/Awesome-prompt-in-CLI
bash main.sh
# Or make it executable and run directly:
chmod +x main.sh
./main.sh
```

**Note**: macOS Catalina+ uses Zsh by default, but Bash is still available.

</details>

### 🧪 Testing

A comprehensive test suite is included to verify cross-platform compatibility:

```bash
bash test/cross_platform_test.sh
```

This runs 10 automated tests covering:
- OS detection
- Path conversion
- Environment detection
- Function exports
- Integration testing



<details>
<summary><strong>📋 Most Common Tasks (Click to expand)</strong></summary>

### 🔍 Find a Prompt
```bash
./scripts/search_prompts.sh machine learning
./scripts/search_prompts.sh -i  # interactive mode
```

### ➕ Add a New Prompt  
```bash
./scripts/add_prompt.sh
# Follow the interactive prompts
```

### 📂 Browse Categories
```bash
./scripts/search_prompts.sh -l  # list all categories
./scripts/manage_categories.sh -l  # list areas/categories
```

### 🌍 Use Different Languages
Navigate to: `Prompts/[LANGUAGE]/` (e.g., `Prompts/ZH/`, `Prompts/JP/`)

</details>

### Using the CLI Tools

We provide four powerful command-line tools to manage and use the prompt collection across all 12 supported languages:

#### 1. Add New Prompts
```bash
./scripts/add_prompt.sh
```
Interactive tool for adding new academic prompts with proper formatting and validation.

#### 2. Search Existing Prompts
```bash
./scripts/search_prompts.sh machine learning
./scripts/search_prompts.sh -c computer-science neural
./scripts/search_prompts.sh -t "Data Analysis"
```
Powerful search tool to find prompts by keywords, categories, or tags.

#### 3. Manage Categories
```bash
./scripts/manage_categories.sh
./scripts/manage_categories.sh -c computer-science
```
Tool for managing Research Areas and Prompt Categories in existing files.

#### 4. Translation Tools
```bash
./scripts/translate_prompts.sh -s
./scripts/translate_prompts.sh -v
./scripts/translate_prompts.sh -c
```
Tool for managing multilingual translations and verifying consistency across all 12 languages.

## 📚 Documentation

All documentation is included in this README file for easy access and maintenance.

<details>
<summary><strong>📖 Detailed Documentation Sections</strong></summary>

- [Detailed Tool Documentation](#-detailed-tool-documentation)
- [Prompt Formatting Guidelines](#-prompt-formatting-guidelines)  
- [Comprehensive Multilingual Support](#-comprehensive-multilingual-support)

</details>

## 🛠️ Features

### Add Prompt Tool (`add_prompt.sh`)
- **🎯 Interactive Interface**: Step-by-step guidance through prompt creation
- **🌍 Cross-Platform**: Works on Linux, macOS, and Windows (Git Bash/WSL)
- **🔍 English Detection**: Warns if content doesn't appear to be in English
- **📊 Auto-Numbering**: Automatically assigns sequential numbers to prompts
- **📋 Category Selection**: Choose from available research areas and prompt categories
- **👀 Preview**: Review your prompt before adding it to the file
- **✅ Validation**: Ensures required fields meet minimum length requirements

### Search Tool (`search_prompts.sh`)
- **🔍 Keyword Search**: Search across all prompts by keywords
- **📂 Category Filtering**: Search within specific academic categories
- **🏷️ Tag-Based Search**: Find prompts by research area or prompt category
- **💬 Interactive Mode**: User-friendly search interface
- **📊 Detailed Results**: Verbose mode shows full prompt details
- **⚡ Fast Performance**: Optimized search algorithms

### Category Management (`manage_categories.sh`)
- **📋 View Current Items**: See all existing Research Areas and Prompt Categories
- **➕ Add New Items**: Easily add new areas or categories
- **🔄 Batch Operations**: Add multiple items in one session
- **✅ Duplicate Prevention**: Prevents adding items that already exist
- **🎯 Interactive Interface**: User-friendly management interface

## 📁 Repository Structure

```
awesome-prompt-for-academic/
├── Prompts/
│   ├── EN/                          # English prompts
│   ├── JP/                          # Japanese prompts (日本語)
│   ├── ZH/                          # Chinese prompts (中文)
│   ├── DE/                          # German prompts (Deutsch)
│   ├── FR/                          # French prompts (Français)
│   ├── ES/                          # Spanish prompts (Español)
│   ├── IT/                          # Italian prompts (Italiano)
│   ├── PT/                          # Portuguese prompts (Português)
│   ├── RU/                          # Russian prompts (Русский)
│   ├── AR/                          # Arabic prompts (العربية)
│   ├── KO/                          # Korean prompts (한국어)
│   └── HI/                          # Hindi prompts (हिन्दी)
│       └── Each folder contains:
│           ├── business-management.md
│           ├── computer-science.md
│           ├── engineering.md
│           ├── general.md
│           ├── humanities.md
│           ├── mathematics-statistics.md
│           ├── medical-sciences.md
│           ├── natural-sciences.md
│           └── social-sciences.md
├── scripts/                         # CLI tools
│   ├── add_prompt.sh               # Tool for adding prompts
│   ├── search_prompts.sh           # Tool for searching prompts
│   └── manage_categories.sh        # Tool for managing categories
├── main.sh                         # Main menu entry point
├── AI-Rules.md                     # AI assistant guidelines
└── README.md                       # This file
```

## 🎨 Prompt Format

All prompts follow a standardized format for consistency:

```markdown
### [Number]. [Descriptive Title]

**Tags:** `Research Area` | `Prompt Category`

**Description:** Brief explanation of what this prompt helps with and when to use it.

**Prompt:**
```
[The actual prompt text goes here]
```
```

## 🚀 Getting Started

### Prerequisites
- Bash 4.0+ (built-in on most systems)
- Write access to the repository (for adding prompts)
- Git (for contributing)

### Installation
1. Clone the repository:
```bash
git clone https://github.com/yourusername/awesome-prompt-for-academic.git
cd awesome-prompt-for-academic
```

2. Make scripts executable:
```bash
chmod +x scripts/add_prompt.sh scripts/search_prompts.sh scripts/manage_categories.sh
```

### Usage Examples

#### Adding a New Prompt
```bash
./scripts/add_prompt.sh
# Follow the interactive prompts to add your academic prompt
```

#### Searching for Prompts
```bash
# Search for machine learning prompts
./scripts/search_prompts.sh machine learning

# Search in computer science category
./scripts/search_prompts.sh -c computer-science neural network

# Interactive search mode
./scripts/search_prompts.sh -i

# Search by tag
./scripts/search_prompts.sh -t "Literature Review"
```

#### Managing Categories
```bash
# Interactive category management
./scripts/manage_categories.sh

# Manage specific category
./scripts/manage_categories.sh -c computer-science

# List all categories and their items
./scripts/manage_categories.sh -l
```

## 🤝 Contributing

We welcome contributions! Here's how to contribute:

1. **Fork the repository**
2. **Add your prompts** using the CLI tool: `./scripts/add_prompt.sh`
3. **Follow the format** specified in [PROMPT_FORMAT.md](PROMPT_FORMAT.md)
4. **Test your prompts** to ensure they work effectively
5. **Submit a pull request** with a clear description

### Contribution Guidelines
- Use the provided CLI tools for consistency
- Follow the standardized prompt format
- Ensure prompts are academic-focused and high-quality
- Test prompts before submitting
- Provide clear, descriptive titles and descriptions

## 📊 Categories Overview

| Category | Research Areas | Prompt Categories |
|----------|----------------|-------------------|
| **Computer Science** | AI, ML, Data Science, Software Engineering | Literature Review, Technical Writing, Code Documentation |
| **Natural Sciences** | Physics, Chemistry, Biology, Environmental Science | Experimental Design, Data Analysis, Research Methodology |
| **Engineering** | Mechanical, Electrical, Civil, Biomedical | Design Process, Technical Documentation, Problem Solving |
| **Medical Sciences** | Clinical Medicine, Public Health, Biomedical Research | Case Studies, Clinical Trials, Evidence-Based Medicine |
| **Social Sciences** | Psychology, Sociology, Political Science | Qualitative Research, Survey Design, Theory Development |
| **Humanities** | Literature, Philosophy, History, Art History | Critical Analysis, Textual Interpretation, Historical Research |
| **Mathematics & Statistics** | Pure Math, Applied Math, Statistics | Proof Writing, Statistical Analysis, Mathematical Modeling |
| **Business & Management** | Strategy, Marketing, Finance, Operations | Case Study Analysis, Strategic Planning, Market Research |
| **General Academic** | Interdisciplinary Studies, Academic Writing, Research Methodology | General Research, Academic Writing, Study Strategies |

## 🔧 Tools Reference

### Quick Commands
```bash
# Add a new prompt
./scripts/add_prompt.sh

# Search for prompts
./scripts/search_prompts.sh [keywords]
./scripts/search_prompts.sh -c [category] [keywords]
./scripts/search_prompts.sh -t "[tag]"
./scripts/search_prompts.sh -i  # interactive mode

# Manage categories
./scripts/manage_categories.sh
./scripts/manage_categories.sh -c [category]
./scripts/manage_categories.sh -l  # list all

# Translation tools
./scripts/translate_prompts.sh -s  # status
./scripts/translate_prompts.sh -v  # verify consistency
./scripts/translate_prompts.sh -c  # count prompts

# Get help
./scripts/add_prompt.sh --help
./scripts/search_prompts.sh --help
./scripts/manage_categories.sh --help
./scripts/translate_prompts.sh --help
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Contributors who have added high-quality academic prompts
- The academic community for inspiration and feedback
- Open source tools and libraries that make this project possible

## 📞 Support

- **Issues**: Report bugs or request features via GitHub Issues
- **Discussions**: Join conversations in GitHub Discussions
- **Documentation**: Check the documentation files for detailed guides

---

## 📖 Detailed Tool Documentation

<details>
<summary><strong>🔧 Add Prompt CLI Tool (add_prompt.sh)</strong></summary>

### Add Prompt CLI Tool (`add_prompt.sh`)

Interactive command-line tool for adding academic prompts following standardized formatting guidelines.

#### Usage
```bash
./scripts/add_prompt.sh
```

#### Features
- **🎯 Interactive Interface**: Step-by-step guidance through prompt creation
- **🌍 Cross-Platform**: Works on Linux, macOS, and Windows (Git Bash/WSL)
- **🔍 English Detection**: Warns if content doesn't appear to be in English
- **📊 Auto-Numbering**: Automatically assigns sequential numbers to prompts
- **📋 Category Selection**: Choose from available research areas and prompt categories
- **👀 Preview**: Review your prompt before adding it to the file
- **✅ Validation**: Ensures required fields meet minimum length requirements

#### Workflow
1. Select academic category (computer-science, natural-sciences, etc.)
2. Enter descriptive prompt title
3. Choose research area from the category's list
4. Choose prompt category from the category's list  
5. Provide 1-2 sentence description
6. Enter the actual prompt text (multi-line supported)
7. Preview the formatted prompt
8. Confirm to add to the markdown file

#### Requirements
- Bash 4.0+ (built-in on most systems)
- Write access to the Prompts/EN/ directory
- English content (warnings shown for non-English text)

#### Example Session
```
🚀 Academic Prompt Addition Tool
Following PROMPT_FORMAT.md guidelines

📂 Select Category:
1. business-management
2. computer-science
3. engineering
...
Select (1-8): 2

📝 Enter prompt title: Research Paper Structure Generator
🔬 Select Research Area: Machine Learning
📋 Select Prompt Category: Technical Writing
📖 Enter description: Generates structured outlines for ML research papers
✍️  Enter the prompt text: (multi-line input)
📋 Preview: (shows formatted prompt)
💾 Add this prompt? (Y/n): y
✅ Prompt successfully added!
```

</details>

<details>
<summary><strong>📂 Category Management Tool (manage_categories.sh)</strong></summary>

### Category Management Tool (`manage_categories.sh`)

Tool for managing Research Areas and Prompt Categories in existing prompt markdown files.

#### Features
- **View existing items**: See all current Research Areas and Prompt Categories
- **Add new items**: Easily add new Research Areas or Prompt Categories
- **Interactive mode**: User-friendly interface for managing categories
- **Batch listing**: View all categories and their items at once
- **Validation**: Prevents duplicate entries

#### Usage

**Interactive Mode (Default)**
```bash
./scripts/manage_categories.sh
```
This launches an interactive menu where you can:
1. Select a category file to manage
2. View existing Research Areas and Prompt Categories
3. Add new items to either section

**Manage Specific Category**
```bash
./scripts/manage_categories.sh -c computer-science
```
Directly manage a specific category file (e.g., `computer-science.md`)

**List All Categories and Items**
```bash
./scripts/manage_categories.sh -l
```
Display all categories with their current Research Areas and Prompt Categories

**Help**
```bash
./scripts/manage_categories.sh --help
```
Show usage information and examples

#### How It Works
1. **Shows Current State**: Before adding anything, the tool displays existing Research Areas and Prompt Categories
2. **Prevents Duplicates**: Checks if an item already exists before adding
3. **Safe Editing**: Uses sed to safely insert new items in the correct sections
4. **Maintains Format**: Preserves the markdown structure and formatting

#### Example Workflow
1. Run `./scripts/manage_categories.sh`
2. Select a category (e.g., "computer-science")
3. View existing Research Areas and Prompt Categories
4. Choose to add a new Research Area or Prompt Category
5. Enter the new item name
6. The tool adds it to the file and confirms success

#### File Structure
The tool works with markdown files in the `Prompts/EN/` directory that have this structure:

```markdown
# Category Title

## Research Areas
- Area 1
- Area 2
- ...

## Prompt Categories
- Category 1
- Category 2
- ...
```

#### Benefits
- **Consistency**: Ensures all category files maintain the same structure
- **Efficiency**: Quick way to add new areas/categories without manual editing
- **Safety**: Prevents accidental duplication or formatting issues
- **Visibility**: Shows what already exists before adding new items

</details>

<details>
<summary><strong>🔍 Search Tool (search_prompts.sh)</strong></summary>

### Search Tool (`search_prompts.sh`)

A CLI tool for searching academic prompts across markdown files with advanced filtering capabilities.

#### Usage
```bash
# Basic search
./scripts/search_prompts.sh machine learning

# Search with options
./scripts/search_prompts.sh -c computer-science neural network
./scripts/search_prompts.sh -t "Data Analysis"
./scripts/search_prompts.sh -i  # interactive mode

# List categories
./scripts/search_prompts.sh -l
```

#### Features
- **🔍 Keyword Search**: Search across all prompts by keywords
- **📂 Category Filtering**: Search within specific academic categories
- **🏷️ Tag-Based Search**: Find prompts by research area or prompt category
- **💬 Interactive Mode**: User-friendly search interface
- **📊 Detailed Results**: Verbose mode shows full prompt details
- **⚡ Fast Performance**: Optimized search algorithms

#### Options
- `-c, --category CATEGORY`: Search in specific category file
- `-t, --tag TAG`: Search by specific tag
- `-a, --area AREA`: Search by research area
- `-i, --interactive`: Interactive search mode
- `-l, --list-categories`: List all available categories
- `-v, --verbose`: Show detailed results
- `--case-sensitive`: Case-sensitive search
- `--exact-match`: Exact phrase matching

</details>

## 📋 Prompt Formatting Guidelines

<details>
<summary><strong>📝 Complete Formatting Guide (Click to expand)</strong></summary>

This section outlines the standard format for adding prompts to the academic prompt collection.

### How to Add Prompts

When contributing a new prompt to any category markdown file, follow this standardized format:

#### Format Structure

```markdown
### [Number]. [Descriptive Title]

**Tags:** `Research Area` | `Prompt Category`

**Description:** Brief explanation of what this prompt helps with and when to use it.

**Prompt:**
```
[The actual prompt text goes here]
```
```

### Rules

1. **Number**: Sequential numbering within each category file (1, 2, 3, etc.)
2. **Title**: Clear, descriptive title that summarizes the prompt's purpose
3. **Tags**: 
   - First tag: One of the Research Areas from the category's markdown file
   - Second tag: One of the Prompt Categories from the category's markdown file
4. **Description**: 1-2 sentences explaining the prompt's use case and benefits
5. **Prompt**: The actual prompt text, enclosed in code blocks for readability

### Examples

#### Computer Science Example

```markdown
### 1. Machine Learning Literature Review Assistant

**Tags:** `Machine Learning` | `Literature Review`

**Description:** Helps structure and organize literature reviews for ML research papers by identifying key themes and research gaps.

**Prompt:**
```
You are an expert machine learning researcher conducting a literature review. Please help me analyze the following papers on [TOPIC] and:

1. Identify the main research themes and approaches
2. Summarize key findings and methodologies 
3. Highlight research gaps and future directions
4. Organize findings into a coherent narrative structure

Papers: [LIST_OF_PAPERS]
```
```

#### Natural Sciences Example

```markdown
### 1. Experimental Design Optimizer

**Tags:** `Biology` | `Experimental Design`

**Description:** Assists in designing robust biological experiments by considering variables, controls, and statistical power.

**Prompt:**
```
As an experienced research biologist, help me design an experiment to investigate [RESEARCH_QUESTION]. Please:

1. Identify key variables (independent, dependent, controlled)
2. Suggest appropriate sample sizes and statistical tests
3. Recommend controls and replication strategies
4. Address potential confounding factors
5. Outline data collection protocols

Research context: [CONTEXT]
Available resources: [RESOURCES]
```
```

### Best Practices

- **Specificity**: Make prompts specific to academic contexts
- **Flexibility**: Use placeholders like [TOPIC], [RESEARCH_QUESTION] for customization
- **Structure**: Include numbered steps or clear instructions
- **Context**: Provide role-based context ("As an expert researcher...")
- **Completeness**: Ensure prompts guide users through complete workflows

### File Organization

- Each category has its own markdown file in `/Prompts/EN/`
- Prompts are numbered sequentially within each file
- Use the Research Areas and Prompt Categories defined in each file for consistent tagging

</details>

## 🌍 Comprehensive Multilingual Support

The repository now supports **12 major academic languages** with complete translations:

### Language Coverage:
- **🇺🇸 English (EN)**: 9 category files
- **🇯🇵 Japanese (JP)**: 9 category files  
- **🇨🇳 Chinese (ZH)**: 9 category files
- **🇩🇪 German (DE)**: 9 category files
- **🇫🇷 French (FR)**: 9 category files
- **🇪🇸 Spanish (ES)**: 9 category files
- **🇮🇹 Italian (IT)**: 9 category files
- **🇵🇹 Portuguese (PT)**: 9 category files
- **🇷🇺 Russian (RU)**: 9 category files
- **🇸🇦 Arabic (AR)**: 9 category files
- **🇰🇷 Korean (KO)**: 9 category files
- **🇮🇳 Hindi (HI)**: 9 category files

**Total: 108 category files across 12 languages**

### Benefits:
- **Global Accessibility**: Researchers worldwide can access prompts in their native language
- **Cultural Adaptation**: Academic terminology properly translated for each language
- **Consistent Quality**: Same high standards maintained across all translations
- **Easy Navigation**: Identical structure across all language folders

---

**Happy researching in your preferred language! 🎓🌍✨**
