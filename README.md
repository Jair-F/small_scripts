# Antivirus Transfer

Add random data before a file to bypass signatures, then remove it later to restore the original.

---

## Linux Usage

<details open>
<summary><strong>Click to expand/collapse Linux instructions</strong></summary>

<details open>
<summary>Interactive Mode (prompts for input)</summary>

**Add data:**
```bash
curl -sL https://raw.githubusercontent.com/Jair-F/small_scripts/refs/heads/master/transfer/add_data.sh | bash
```

**Remove data:**
```bash
curl -sL https://raw.githubusercontent.com/Jair-F/small_scripts/refs/heads/master/transfer/remove_data.sh | bash
```

</details>

<details>
<summary>Command-line Arguments</summary>

**Add data with parameters:**
```bash
curl -sL https://raw.githubusercontent.com/Jair-F/small_scripts/refs/heads/master/transfer/add_data.sh | bash -s myfile.pdf 8
```
- `myfile.pdf` - Input file path
- `8` - Number of KB to add (default: 4, max: 99)

**Remove data with parameters:**
```bash
curl -sL https://raw.githubusercontent.com/Jair-F/small_scripts/refs/heads/master/transfer/remove_data.sh | bash -s myfile.pdf.bin
```
- `myfile.pdf.bin` - Input file (size is read from the file itself)

</details>

</details>

---

## Windows Usage

<details>
<summary><strong>Click to expand/collapse Windows instructions</strong></summary>

**Initial Setup** (one-time):
```powershell
Set-ExecutionPolicy Unrestricted -Scope CurrentUser
```

<details open>
<summary>Interactive Mode (prompts for input)</summary>

**Add data:**
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Jair-F/small_scripts/refs/heads/master/transfer/add_data.ps1" | Select-Object -ExpandProperty Content | Invoke-Expression
```

**Remove data:**
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Jair-F/small_scripts/refs/heads/master/transfer/remove_data.ps1" | Select-Object -ExpandProperty Content | Invoke-Expression
```

</details>

<details>
<summary>Command-line Arguments</summary>

**Add data with parameters:**
```powershell
$code = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Jair-F/small_scripts/refs/heads/master/transfer/add_data.ps1").Content; Invoke-Expression $code -InputFile "myfile.pdf" -NumOfKBytes 8
```
- `-InputFile` - Path to input file
- `-NumOfKBytes` - Number of KB to add (default: 4)

**Remove data with parameters:**
```powershell
$code = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Jair-F/small_scripts/refs/heads/master/transfer/remove_data.ps1").Content; Invoke-Expression $code -InputFile "myfile.pdf.bin"
```
- `-InputFile` - Path to input file (size is read from the file itself)

</details>

</details>

---

## Notes

- Max 99 KB per operation (Linux)
- Output: `originalfile.bin` from add_data, original name from remove_data
