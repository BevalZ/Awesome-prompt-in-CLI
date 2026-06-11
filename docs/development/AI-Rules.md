# AI Assistant Rules for Academic Prompt Management

This document provides instructions for AI coding assistants (Claude Code, Gemini CLI, etc.) to automatically help add prompts to the Awesome Academic Prompts repository.

## 🎯 Your Role

When a user provides a prompt body, you should:
1. **Detect the input language** (English, Japanese, or Chinese)
2. **Analyze the prompt content** to determine the appropriate academic category
3. **Generate a descriptive title** that summarizes the prompt's purpose
4. **Select or create appropriate tags** from the available Research Areas and Prompt Categories
5. **Write a concise description** explaining the prompt's use case
6. **Add the prompt** to the correct markdown file in the input language first
7. **Translate and add** the prompt to all other language folders

### Language Handling Rules:
- **Primary Addition**: Always add to the folder matching the input language first
- **Translation Requirement**: After adding to the primary language, translate and add to ALL other language folders
- **Consistency**: Maintain the same category and tags across all languages

## 📂 Available Categories

The repository contains these academic categories in 12 major academic languages:
- **English**: `Prompts/EN/` 🇺🇸
- **Japanese**: `Prompts/JP/` 🇯🇵
- **Chinese**: `Prompts/ZH/` 🇨🇳
- **German**: `Prompts/DE/` 🇩🇪
- **French**: `Prompts/FR/` 🇫🇷
- **Spanish**: `Prompts/ES/` 🇪🇸
- **Italian**: `Prompts/IT/` 🇮🇹
- **Portuguese**: `Prompts/PT/` 🇵🇹
- **Russian**: `Prompts/RU/` 🇷🇺
- **Arabic**: `Prompts/AR/` 🇸🇦
- **Korean**: `Prompts/KO/` 🇰🇷
- **Hindi**: `Prompts/HI/` 🇮🇳

### Categories in `Prompts/EN/` (and corresponding translations):

- **business-management.md** - Business Strategy, Marketing, Finance, Operations, HR, etc.
- **computer-science.md** - AI, Machine Learning, Software Engineering, Data Science, etc.
- **engineering.md** - Mechanical, Electrical, Civil, Chemical, Biomedical Engineering, etc.
- **general.md** - Interdisciplinary, Academic Writing, Research Methods, Study Skills, etc.
- **humanities.md** - Literature, Philosophy, History, Art History, Cultural Studies, etc.
- **mathematics-statistics.md** - Pure Math, Applied Math, Statistics, Operations Research, etc.
- **medical-sciences.md** - Clinical Medicine, Public Health, Biomedical Research, etc.
- **natural-sciences.md** - Physics, Chemistry, Biology, Environmental Science, etc.
- **social-sciences.md** - Psychology, Sociology, Political Science, Economics, etc.

## 🏷️ Tag Selection Process

### Step 1: Choose Research Area
Select the most appropriate Research Area from the target category file. Examples:
- Computer Science: `Machine Learning`, `Data Science`, `Software Engineering`
- Natural Sciences: `Biology`, `Chemistry`, `Physics`
- Business: `Marketing`, `Finance`, `Strategic Planning`

**If no appropriate Research Area exists**: Add a new one to the category file's Research Areas section.

### Step 2: Choose Prompt Category
Select the most appropriate Prompt Category from the target category file. Examples:
- `Literature Review`, `Research Methodology`, `Data Analysis`
- `Technical Writing`, `Experimental Design`, `Case Study Analysis`
- `Problem Solving`, `Grant Proposals`, `Statistical Analysis`

**If no appropriate Prompt Category exists**: Add a new one to the category file's Prompt Categories section.

## 📝 Required Format

When adding a prompt, use this exact format:

```markdown
### [Descriptive Title]

**Tags:** `[Research Area]` | `[Prompt Category]`

**Description:** [1-2 sentences explaining the prompt's use case and benefits]

**Prompt:**
```
[The actual prompt text goes here]
```
```

## 📇 Prompt Index System

The repository uses a position-based indexing system to enable cross-language prompt copying functionality. This system allows users to find the same prompt in different languages even when titles are translated.

### Index File Location
- **File**: `Prompts/prompt_index.json`
- **Purpose**: Maps prompts across languages by unique ID and position within category files
- **Format**: JSON structure with categories, prompt IDs, positions, and metadata

### Index Structure
```json
{
  "version": "1.0",
  "description": "Index mapping prompts across different languages by unique ID and position",
  "categories": {
    "category-name": {
      "prompts": [
        {
          "id": "category_001",
          "position": 1,
          "en_title": "English Title",
          "description": "Brief description of the prompt's purpose"
        }
      ]
    }
  }
}
```

### Index Maintenance Rules

When adding a new prompt, you **MUST**:

1. **Update the index file** (`Prompts/prompt_index.json`)
2. **Assign a unique ID** following the pattern: `{category}_{number}` (e.g., `general_014`, `medical_004`)
3. **Set the correct position** based on the prompt's order in the category file
4. **Use the English title** as the reference title in the index
5. **Add a brief description** for identification purposes

### Position-Based Matching

The system works by:
- **Position tracking**: Each prompt has a specific position within its category file (1st, 2nd, 3rd, etc.)
- **Cross-language mapping**: The same position in different language files contains the translated version
- **Consistent ordering**: All language versions maintain the same prompt order within each category

### Index ID Naming Convention

Use this format for prompt IDs:
- **general**: `general_001`, `general_002`, etc.
- **computer-science**: `cs_001`, `cs_002`, etc.
- **medical-sciences**: `medical_001`, `medical_002`, etc.
- **natural-sciences**: `natural_001`, `natural_002`, etc.
- **social-sciences**: `social_001`, `social_002`, etc.
- **humanities**: `humanities_001`, `humanities_002`, etc.
- **mathematics-statistics**: `math_001`, `math_002`, etc.
- **business-management**: `business_001`, `business_002`, etc.
- **engineering**: `engineering_001`, `engineering_002`, etc.

### Example Index Entry

When adding a new prompt to `general.md`:

```json
{
  "id": "general_014",
  "position": 14,
  "en_title": "Research Methodology Advisor",
  "description": "Provides guidance on selecting appropriate research methodologies"
}
```

### Index Update Process

1. **Count existing prompts** in the target category to determine the next position
2. **Generate unique ID** using the category prefix and next number
3. **Add entry to index** with all required fields
4. **Verify position accuracy** across all language files
5. **Maintain alphabetical order** of categories in the index file

### Critical Index Rules

- **Never skip positions**: Positions must be sequential (1, 2, 3, 4...)
- **Never reuse IDs**: Each prompt gets a unique ID that's never reused
- **Always update index**: Every new prompt requires an index entry
- **Maintain consistency**: Same position = same prompt across all languages
- **Use English titles**: Index always uses English title as reference

### Index Benefits

This system enables:
- **Cross-language copying**: Users can copy prompts in any language
- **Consistent navigation**: Same prompt structure across all languages
- **Easy maintenance**: Clear mapping between language versions
- **Search functionality**: Enhanced search and filtering capabilities
- **Quality assurance**: Verification that all languages have matching prompts

## 🔍 Content Analysis Guidelines

### Determine Category by Keywords:
- **AI/ML/Data terms** → computer-science.md
- **Business/Marketing/Finance terms** → business-management.md
- **Biology/Chemistry/Physics terms** → natural-sciences.md
- **Psychology/Sociology terms** → social-sciences.md
- **Engineering/Design terms** → engineering.md
- **Literature/History/Philosophy terms** → humanities.md
- **Math/Statistics terms** → mathematics-statistics.md
- **Medical/Health terms** → medical-sciences.md
- **Academic Writing/Research Methods/Study Skills/Interdisciplinary terms** → general.md

**If no appropriate category exists**: Default to **general.md** for any prompt that doesn't clearly fit into the specific disciplinary categories.

### Title Generation Rules:
- Use descriptive, action-oriented titles
- Include the main purpose or outcome
- Keep titles concise (5-8 words ideal)
- Examples: "Literature Review Assistant", "Data Analysis Optimizer", "Research Proposal Generator"

### Description Writing:
- First sentence: What the prompt does
- Second sentence: When/why to use it
- Focus on academic benefits and use cases
- Keep it concise but informative

## 📋 Step-by-Step Process

When a user provides a prompt body:

### 1. Language Detection & Analysis
```
- Detect input language (EN/JP/ZH)
- Read the prompt text
- Identify key academic domain
- Determine primary use case
- Select target category file (default to general.md if unclear)
```

### 2. Generate Metadata
```
- Create descriptive title
- Select or create Research Area tag
- Select or create Prompt Category tag  
- Write 1-2 sentence description
```

### 3. Index Management
```
- Count existing prompts in target category to determine next position
- Generate unique ID using category prefix (e.g., general_014, cs_005)
- Update Prompts/prompt_index.json with new entry
- Include: id, position, en_title, description
```

### 4. Primary Addition
```
- Format according to template
- Add to appropriate category file in INPUT LANGUAGE first
- If new tags were created, add them to the category file's sections
- Ensure prompt is added at the correct position for index consistency
```

### 5. Translation & Cross-Language Addition
```
- Translate the prompt, title, and description to ALL 11 other languages
- Add translated versions to corresponding category files in ALL language folders
- Languages: EN, JP, ZH, DE, FR, ES, IT, PT, RU, AR, KO, HI
- Maintain same category and position across all 12 languages
- Ensure consistency in formatting and academic terminology
- Verify all language files have the same number of prompts
```

## ✅ Quality Checklist

Before adding a prompt, verify:
- [ ] Content is academic/research-focused
- [ ] Category selection is appropriate (use general.md if no clear fit)
- [ ] Tags exist in the target category file OR new appropriate tags are added
- [ ] Title is descriptive and clear
- [ ] Description explains use case and benefits
- [ ] Format matches the template exactly
- [ ] Prompt text is preserved exactly as provided
- [ ] **Index entry created** in `Prompts/prompt_index.json`
- [ ] **Unique ID assigned** following naming convention
- [ ] **Position number is correct** and sequential
- [ ] Added to input language folder first
- [ ] Translated and added to all other language folders
- [ ] **Same position maintained** across all language files
- [ ] Consistency maintained across all language versions
- [ ] **All language files have same prompt count** after addition

## 🚫 What NOT to Do

- Don't modify the user's prompt text content
- Don't skip adding new Research Areas or Prompt Categories when needed
- Don't use generic or inappropriate tags
- Don't skip the description or make it too generic
- Don't add prompts to wrong categories (use general.md when uncertain)
- **Don't forget to update the prompt index** (`Prompts/prompt_index.json`)
- **Don't skip position numbers** or create gaps in numbering
- **Don't reuse prompt IDs** that have been used before
- **Don't add prompts at different positions** across language files
- Don't forget to translate and add to all language folders
- Don't create inconsistencies between language versions
- **Don't leave language files with different prompt counts**

## 💡 Example Workflow

**User provides (in English):** "Help me analyze survey data and identify statistical patterns"

**Your analysis:**
- Input Language: English
- Domain: Statistics/Data Analysis
- Category: mathematics-statistics.md
- Research Area: Statistics (exists)
- Prompt Category: Statistical Analysis (exists)
- Title: "Survey Data Pattern Analyzer"

**Your response:**
```markdown
I'll add this prompt to mathematics-statistics.md in all languages:

**Index Entry Added:**
```json
{
  "id": "math_003",
  "position": 3,
  "en_title": "Survey Data Pattern Analyzer",
  "description": "Assists researchers in analyzing survey data to identify statistical patterns"
}
```

### English (EN/mathematics-statistics.md):
### Survey Data Pattern Analyzer

**Tags:** `Statistics` | `Statistical Analysis`

**Description:** Assists researchers in analyzing survey data to identify meaningful statistical patterns and relationships. Useful for quantitative research projects requiring systematic data interpretation.

**Prompt:**
```
Help me analyze survey data and identify statistical patterns
```

### Japanese (JP/mathematics-statistics.md):
### 調査データパターン分析器

**Tags:** `統計学` | `統計分析`

**Description:** 調査データを分析し、意味のある統計的パターンと関係を特定する研究者を支援します。体系的なデータ解釈を必要とする定量的研究プロジェクトに有用です。

**Prompt:**
```
調査データを分析し、統計的パターンを特定するのを手伝ってください
```

### Chinese (ZH/mathematics-statistics.md):
### 调查数据模式分析器

**Tags:** `统计学` | `统计分析`

**Description:** 协助研究人员分析调查数据，识别有意义的统计模式和关系。适用于需要系统数据解释的定量研究项目。

**Prompt:**
```
帮助我分析调查数据并识别统计模式
```

✅ Successfully added to all language versions with index entry!
✅ Position 3 maintained across all 12 language files
✅ Index updated with unique ID: math_003
```

**Example with new tags needed:**

**User provides:** "Help me design virtual reality experiments for psychology research"

**Your analysis:**
- Input Language: English
- Domain: Psychology + Technology (interdisciplinary)
- Category: social-sciences.md (closest fit)
- Research Area: Psychology (exists)
- Prompt Category: "VR Experiment Design" (NEW - needs to be added)
- Title: "VR Psychology Experiment Designer"

**Your actions:**
1. Add "VR Experiment Design" to Prompt Categories in social-sciences.md (all languages)
2. Add the prompt with this new category
3. Translate to all languages

## 🎯 Success Criteria

A successful prompt addition should:
1. **Be in the right category** based on content analysis (or general.md if unclear)
2. **Have appropriate tags** that exist or are newly created when needed
3. **Include a clear, descriptive title**
4. **Provide a helpful description** of use cases
5. **Follow the exact formatting** specified
6. **Preserve the original prompt text** exactly
7. **Have a proper index entry** with unique ID and correct position
8. **Be added to input language first**, then translated to all other languages
9. **Maintain the same position** across all 12 language files
10. **Maintain consistency** across all language versions
11. **Add new tags to category files** when appropriate tags don't exist
12. **Keep all language files synchronized** with the same prompt count

## 🎯 When to Use General Category

Use **general.md** for prompts that:
- Are interdisciplinary and don't fit a specific domain
- Focus on general academic skills (writing, research methods, study skills)
- Deal with academic career development or professional skills
- Cover general research methodology applicable across disciplines
- Address academic ethics, collaboration, or communication skills
- Are about academic productivity, time management, or organization
- **Don't clearly fit into any specific disciplinary category** (DEFAULT FALLBACK)

**Important**: When in doubt about categorization, always default to general.md rather than forcing a prompt into an inappropriate specific category.

## 📞 When to Ask for Clarification

Ask the user for clarification when:
- The prompt could fit multiple categories equally well
- The prompt content is too generic to categorize
- The prompt appears to be non-academic in nature
- You're unsure about the intended use case

## 🌍 Multilingual Workflow Summary

1. **Detect input language** (EN/JP/ZH/DE/FR/ES/IT/PT/RU/AR/KO/HI)
2. **Add to input language folder first**
3. **Translate and add to ALL 11 other language folders**
4. **Create new tags if needed** (in all 12 languages)
5. **Use general.md as fallback** for unclear categorization
6. **Maintain consistency** across all 12 language versions

### Supported Languages:
🇺🇸 EN | 🇯🇵 JP | 🇨🇳 ZH | 🇩🇪 DE | 🇫🇷 FR | 🇪🇸 ES | 🇮🇹 IT | 🇵🇹 PT | 🇷🇺 RU | 🇸🇦 AR | 🇰🇷 KO | 🇮🇳 HI

Remember: Your goal is to make it effortless for users to add high-quality, properly formatted prompts to the repository while maintaining consistency, organization, and comprehensive multilingual support.
