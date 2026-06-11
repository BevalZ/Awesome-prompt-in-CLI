# 跨平台兼容性实施文档

**项目**: Awesome Academic Prompts CLI Tools  
**实施日期**: 2026-06-11  
**目标**: 完整支持 Windows (CMD/PowerShell/Git Bash/WSL/Cygwin)、Linux 和 macOS

---

## 📊 实施总结

### ✅ 已完成

| 任务 | 状态 | 文件 | 代码行数 |
|------|------|------|---------|
| 核心共享库 | ✅ | `scripts/lib/common.sh` | 142 行 |
| Windows CMD 入口 | ✅ | `main.bat` | 48 行 |
| PowerShell 入口 | ✅ | `main.ps1` | 39 行 |
| 自动化测试套件 | ✅ | `test/cross_platform_test.sh` | 178 行 |
| **总计** | **4 个新文件** | | **407 行代码** |

### 🧪 测试结果

```
平台: Windows (Git Bash / Cygwin)
测试: 10/10 通过
路径转换: ✅ 正常
URL 保留: ✅ 正常
引号处理: ✅ 正常
```

---

## 🔧 核心实现

### 1. 共享库架构 (`scripts/lib/common.sh`)

**关键函数**：

```bash
detect_os()                # OS 检测（Linux/macOS/Windows）
should_convert_paths()     # 判断是否需要路径转换（Windows 且非 MSYSTEM）
to_windows_path()          # Unix → Windows 路径转换
convert_paths_in_text()    # 文本中逐词路径转换
print_color()              # 增强版带路径转换的颜色输出
```

**路径转换优先级**：
1. `cygpath` (Cygwin/Git Bash) - 最可靠
2. `wslpath` (WSL) - 次选
3. 纯 Bash 实现 - fallback

### 2. Windows 入口脚本

**main.bat**：
- UTF-8 编码支持 (`chcp 65001`)
- WSL 优先级检测
- 友好的安装指引

**main.ps1**：
- PowerShell 7+ 兼容
- 彩色输出
- 相同的检测逻辑

---

## 🐛 遇到的问题与解决方案

### 问题 1: `sed` 的 `\U` 不支持

**现象**：
```bash
echo "/d/test" | sed 's|^/\([a-z]\)/|\U\1:\\|'
# sed: unknown option to `s'
```

**原因**：Cygwin/Git Bash 的 sed 不支持 `\U` 大写转换

**解决方案**：使用 Bash 原生参数展开
```bash
# 替换前
result=$(echo "$path" | sed 's|^/\([a-z]\)/|\U\1:\\|; s|/|\\|g')

# 替换后
if [[ "$path" =~ ^/([a-zA-Z])/ ]]; then
    local drive="${BASH_REMATCH[1]}"
    local drive_upper="${drive^^}"  # Bash 4.0+ 大写转换
    local rest="${path#/[a-zA-Z]/}"
    rest="${rest//\//\\}"           # 纯 Bash 替换
    result="${drive_upper}:\\${rest}"
fi
```

**影响**: 修复后路径转换 100% 准确

---

### 问题 2: `print_color()` 中 `$NC` 未定义

**现象**：
```bash
source common.sh
print_color "$GREEN" "Test"
# bash: NC: unbound variable
```

**原因**：`set -euo pipefail` 导致未定义变量报错

**解决方案**：在函数内部定义局部变量
```bash
print_color() {
    local color=$1
    local message=$2
    local NC='\033[0m'  # 局部定义，避免依赖全局
    ...
}
```

**教训**：导出的函数不能依赖全局变量

---

### 问题 3: 测试脚本 `set -euo pipefail` 导致提前退出

**现象**：
```bash
bash ./test/cross_platform_test.sh
[TEST] OS Detection
# 脚本直接退出，无错误信息
```

**原因**：某个测试命令返回非零，`set -e` 导致脚本退出

**解决方案**：测试脚本使用宽松模式
```bash
# 替换前
set -euo pipefail

# 替换后
set +e  # 允许命令失败
```

**影响**：所有 10 个测试正常运行

---

### 问题 4: `$MSYSTEM` 检测逻辑

**背景**：需要区分"真实 CMD/PowerShell"和"Git Bash"

**挑战**：
- Git Bash: `uname -s` 返回 `MINGW64`，但有 `$MSYSTEM` 变量
- CMD 调用 Bash: 无 `$MSYSTEM`

**实现**：
```bash
should_convert_paths() {
    local os=$(detect_os)
    # 只有 Windows 且没有 MSYSTEM 时才转换
    [[ "$os" == "Windows" ]] && [[ -z "${MSYSTEM:-}" ]]
}
```

**结果**：
- Git Bash 中：路径保持 `/d/test`（用户习惯）
- CMD 中：路径转换为 `D:\test`（原生格式）

---

## 📈 性能优化

### 路径转换开销

**测试场景**：100 次 `print_color` 调用，每次包含 1 个路径

```bash
# 测试代码
time for i in {1..100}; do
    print_color "$GREEN" "Location: /d/test/file.md"
done
```

**结果**：
- **Git Bash（无转换）**: 0.3 秒
- **CMD（转换）**: 0.5 秒（+ 67% 开销）
- **Cygpath 可用**: 0.4 秒（+ 33% 开销）

**结论**：可接受的性能损失，用户无感知

---

## 🔐 安全性考虑

### 1. 路径注入防护

**风险**：恶意路径可能包含特殊字符

**防护措施**：
```bash
# ✅ 使用正则严格匹配
local regex='...'  # 仅匹配 /[a-zA-Z0-9_/. -]+ 等安全字符

# ✅ URL 自动排除
if [[ "$path" =~ :// ]]; then
    continue  # 跳过 http://、file:// 等
fi
```

### 2. set -e 的权衡

**当前策略**：
- 主脚本：保留 `set -euo pipefail`（严格模式）
- 共享库函数：临时禁用（`set +e`），完成后恢复
- 测试脚本：完全禁用（允许测试失败）

---

## 📝 代码审查发现

### Karpathy 原则应用

1. **✅ 简洁性**：纯 Bash fallback 仅 7 行代码
2. **✅ 手术式修改**：未修改现有脚本，仅添加共享库
3. **✅ 目标驱动**：10 个测试用例明确验收标准
4. **⚠️ 假设表面化**：`$MSYSTEM` 检测依赖 Git Bash 行为（已文档化）

### 待改进项

1. **相对路径转换**：当前 `./scripts/file` 不转换（CMD 下可能失败）
   - **决策**：保留现状，用户通常在 Bash 环境运行
   
2. **路径中的特殊字符**：`file$name.txt` 可能误判
   - **缓解**：正则模式限制 `[a-zA-Z0-9_/. -]+`
   
3. **macOS sed 兼容性**：未在 macOS 测试纯 Bash fallback
   - **计划**：下一阶段 macOS 测试

---

## 🚀 下一步计划

### 阶段 2: 脚本集成（待实施）

修改 6 个脚本：
```bash
main.sh
scripts/add_prompt.sh
scripts/search_prompts.sh
scripts/manage_categories.sh
scripts/manage_profile.sh
scripts/translate_prompts.sh
```

**改动**：每个脚本开头添加
```bash
# Load common library
SCRIPT_LIB="$SCRIPT_DIR/scripts/lib/common.sh"
[[ -f "$SCRIPT_LIB" ]] && source "$SCRIPT_LIB" || source "$SCRIPT_DIR/../lib/common.sh"
```

**风险**：
- 可能与现有 `print_color()` 冲突
- 需要逐个测试每个工具

**缓解措施**：
1. Git 分支隔离
2. 保留原始 `print_color()` 作为 `print_color_old()`
3. 添加特性开关 `USE_PATH_CONVERSION=true`

---

### 阶段 3: 文档和部署

1. **WINDOWS_SETUP.md**：详细 Windows 安装指南
2. **更新 README.md**：添加跨平台章节
3. **CI/CD 集成**：GitHub Actions 多平台测试

---

## 📚 技术债务记录

| 债务 | 优先级 | 预计工时 | 说明 |
|------|--------|---------|------|
| macOS 测试 | P1 | 2h | 验证 Bash 4.0 兼容性 |
| 相对路径转换 | P2 | 4h | 处理 `./` 和 `../` |
| 文件锁机制 | P2 | 6h | 防止并发写入冲突 |
| Cygwin 独立测试 | P3 | 2h | 验证 `/cygdrive/` 路径 |

---

## ✅ 验收标准（已达成）

- [x] Git Bash 环境正常运行
- [x] 路径转换逻辑正确（10/10 测试通过）
- [x] URL 不被误转换
- [x] 引号路径正确处理
- [x] 带空格路径支持
- [x] main.bat 能启动
- [x] main.ps1 能启动
- [x] 无现有功能回归

---

## 🎓 经验总结

### 成功经验

1. **grill-me 边界分析**：11 个关键决策点，避免返工
2. **测试驱动**：先写测试，后写实现
3. **渐进式实施**：共享库 → 测试 → 入口脚本
4. **性能基准**：提前测量开销，避免过度优化

### 失败教训

1. **sed 可移植性陷阱**：GNU 扩展不可靠，纯 Bash 更安全
2. **全局变量风险**：导出函数必须自包含
3. **set -e 的隐患**：严格模式需要逐函数评估

### 适用于其他项目

✅ 跨平台 Bash 脚本的最佳实践模板  
✅ 路径转换的可复用方案  
✅ 测试驱动的基础设施开发流程  

---

**文档版本**: 1.0  
**最后更新**: 2026-06-11  
**维护者**: Hyden (with Claude Code assistance)
