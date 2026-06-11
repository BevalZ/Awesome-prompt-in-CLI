# DeepLX API Integration Guide

## Overview

The awesome-prompt-for-academic toolkit now includes **DeepLX API integration** for seamless translation of academic prompts across 12 languages.

DeepLX is a free, high-quality translation API that can be used to:
- Translate individual prompts
- Translate entire category files
- Batch translate multiple files to multiple languages
- Preserve markdown formatting during translation

## Getting Started

### 1. Configure DeepLX API

#### Option A: Using the CLI Configuration Tool

```bash
./scripts/translate_prompts.sh --configure-api
```

This will prompt you to:
1. Enable/disable the DeepLX API
2. Enter your DeepLX API key (if enabling)
3. Optionally specify a custom API endpoint (defaults to `https://api.deeplx.org/translate`)

#### Option B: Manual Configuration

Edit `Profiles/user_profile.conf` and add/update:

```ini
DEEPLX_API_ENABLED=true
DEEPLX_API_KEY=your_api_key_here
DEEPLX_API_ENDPOINT=https://api.deeplx.org/translate
DEEPLX_DEFAULT_SOURCE_LANG=EN
AUTO_TRANSLATE_ENABLED=false
```

### 2. Getting an API Key

1. Visit [DeepLX API](https://www.deeplx.org/) 
2. Sign up for a free account
3. Generate an API key from your dashboard
4. Add the key to your configuration (see above)

**Note**: DeepLX offers a free tier with reasonable rate limits for academic use.

## Usage

### Check Translation Status

View the current translation status across all languages:

```bash
./scripts/translate_prompts.sh -s
```

### Verify Consistency

Check that all language files have the same structure:

```bash
./scripts/translate_prompts.sh -v
```

### Count Prompts

See how many prompts are in each language:

```bash
./scripts/translate_prompts.sh -c
```

### Translate a Single Prompt

Translate one specific prompt from one language to another:

```bash
./scripts/translate_prompts.sh --translate-prompt \
  --source-lang EN \
  --target-lang ZH \
  --category general \
  --prompt-title "Your Prompt Title Here"
```

**Parameters:**
- `--source-lang`: Source language code (default: EN)
- `--target-lang`: Target language code
- `--category`: Category file name (without `.md`)
- `--prompt-title`: Exact title of the prompt to translate

**Supported Languages:**
- EN (English)
- ZH (Chinese)
- JP (Japanese)
- DE (German)
- FR (French)
- ES (Spanish)
- IT (Italian)
- PT (Portuguese)
- RU (Russian)
- AR (Arabic)
- KO (Korean)
- HI (Hindi)

### Translate a Full Category File

Translate an entire category file from one language to another:

```bash
./scripts/translate_prompts.sh --translate-file \
  --source-lang EN \
  --target-lang ZH \
  --category general
```

The script will:
1. Create a backup of the existing target file (if it exists)
2. Translate the entire file while preserving markdown structure
3. Save the translated file to `Prompts/{TARGET_LANG}/{category}.md`

### Batch Translate Multiple Files

Translate all 9 category files to multiple languages at once:

```bash
./scripts/translate_prompts.sh --batch-translate \
  --source-lang EN \
  --target-lang ZH,FR,DE
```

This will translate all category files from English to Chinese, French, and German.

### View Help

```bash
./scripts/translate_prompts.sh --help
```

## Features

### ✅ Implemented Features

1. **API Configuration Management**
   - Easy setup via CLI configuration tool
   - Secure storage in user profile
   - Support for custom endpoints

2. **Single Prompt Translation**
   - Translate individual prompts by title
   - Preserves markdown formatting
   - Supports all 12 languages

3. **Full File Translation**
   - Translate entire category files
   - Automatic backup creation
   - Markdown structure preservation

4. **Batch Translation**
   - Translate to multiple languages simultaneously
   - All 9 categories processed
   - Progress tracking

5. **Error Handling**
   - API timeout handling with retries (3 attempts)
   - Rate limit detection and exponential backoff
   - Authentication error detection
   - Graceful error messages

6. **Status Management**
   - View translation status across all languages
   - Verify file consistency
   - Count prompts per language
   - Language overview

### 🔄 Markdown Preservation

The translation system intelligently preserves markdown formatting:
- Headings (# ## ###) are preserved
- Lists and bullet points remain unchanged
- Empty lines are maintained
- Code blocks and special formatting are protected

### ⚠️ Error Handling

The system implements robust error handling:

- **Timeouts**: Automatically retries up to 3 times with 2-second delays
- **Rate Limits**: Detects 429 errors and backs off exponentially
- **Authentication Errors**: Clearly indicates API key issues
- **Network Errors**: Gracefully handles connection failures

## Integration with Main Menu

The DeepLX translation tools are accessible from the main menu:

1. Run `./main.sh`
2. Select **5. Translation Tools** from the main menu
3. Select **5. DeepLX Translation Tool**
4. Choose an option:
   - Configure API
   - Translate Prompt (CLI instructions provided)
   - Translate File (CLI instructions provided)
   - Batch Translate (CLI instructions provided)

## Advanced Usage

### Custom API Endpoint

If you're using a different DeepLX-compatible API:

```bash
# Edit the profile
nano Profiles/user_profile.conf

# Update the endpoint
DEEPLX_API_ENDPOINT=https://your-custom-endpoint.com/translate
```

### Disabling Translation

To disable the DeepLX API:

```bash
./scripts/translate_prompts.sh --configure-api
# Select 'n' when prompted
```

Or edit `Profiles/user_profile.conf`:

```ini
DEEPLX_API_ENABLED=false
```

## Troubleshooting

### "API is not configured" Error

**Solution**: Run `./scripts/translate_prompts.sh --configure-api` and enter your API key.

### "Authentication failed" Error

**Solution**: Check that your API key is correct:
```bash
# View configuration
cat Profiles/user_profile.conf

# Reconfigure
./scripts/translate_prompts.sh --configure-api
```

### "Rate limit exceeded" Error

**Solution**: The system automatically retries with exponential backoff. If this persists, wait before attempting again or check your API usage on the DeepLX dashboard.

### "Request timeout" Error

**Solution**: The system automatically retries. If timeouts persist:
1. Check your internet connection
2. Verify the API endpoint is accessible
3. Try again later if the API is experiencing issues

### Translation Quality Issues

If translations don't meet your expectations:
1. DeepLX is a general-purpose API; academic terminology may need manual review
2. Consider using the single prompt translation feature to verify quality before batch operations
3. Create backups (automatically done) before overwriting translations
4. Review and manually edit critical translations

## Best Practices

### 1. Test Before Batch Operations

```bash
# Test with a single prompt first
./scripts/translate_prompts.sh --translate-prompt \
  --source-lang EN --target-lang ZH \
  --category general --prompt-title "Sample Prompt"

# Then do batch if quality is acceptable
./scripts/translate_prompts.sh --batch-translate \
  --source-lang EN --target-lang ZH
```

### 2. Verify Consistency After Translation

```bash
# Always verify the integrity after translation
./scripts/translate_prompts.sh -v
```

### 3. Keep Backups

The system automatically creates backups before overwriting files (`.bak` extension). Keep these until you're satisfied with the translations.

### 4. Review Technical Terms

Academic and technical terms may need manual review and adjustment. Consider:
- Reviewing one category at a time
- Editing any terminology-specific translations
- Using your domain expertise to improve quality

## Configuration Reference

### user_profile.conf Settings

```ini
# Enable/disable DeepLX API
DEEPLX_API_ENABLED=true|false

# Your DeepLX API key
DEEPLX_API_KEY=your_key_here

# API endpoint (optional, uses default if not specified)
DEEPLX_API_ENDPOINT=https://api.deeplx.org/translate

# Default source language for translations
DEEPLX_DEFAULT_SOURCE_LANG=EN

# Auto-translate new prompts (currently not implemented)
AUTO_TRANSLATE_ENABLED=true|false
```

## Supported Language Codes

| Code | Language |
|------|----------|
| EN   | English |
| ZH   | Chinese (Simplified) |
| JP   | Japanese |
| DE   | German |
| FR   | French |
| ES   | Spanish |
| IT   | Italian |
| PT   | Portuguese |
| RU   | Russian |
| AR   | Arabic |
| KO   | Korean |
| HI   | Hindi |

## API Requirements

- **Free Tier**: Typically 500,000 characters/month
- **Rate Limits**: Usually 200 requests/minute
- **Authentication**: Bearer token in Authorization header
- **Request Format**: JSON with text, source_language, target_language
- **Response Format**: JSON with translated data

## Performance Notes

- **Single Prompt**: ~1-2 seconds per request
- **File Translation**: ~5-30 seconds depending on file size
- **Batch Operation**: 5-15 minutes for all categories to all languages
- **Retry Logic**: Automatically handles timeouts and rate limits

## Future Enhancements

Potential features for future versions:
- Interactive prompt selection for translation
- Translation quality verification tools
- Glossary support for consistent terminology
- Comparison between different translation versions
- Auto-detection of language from source
- Translation caching for identical content

## Support

For issues or questions:
1. Check the [Troubleshooting](#troubleshooting) section
2. Review the [Best Practices](#best-practices) section
3. Check DeepLX documentation at https://www.deeplx.org/
4. Review the help messages: `./scripts/translate_prompts.sh --help`

## License

The DeepLX integration is part of the awesome-prompt-for-academic toolkit and follows the same license as the main project.
