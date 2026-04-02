# Antivirus Transfer

Add random data before a file to bypass signatures, then remove it later to restore the original.

## Windows Usage

<details open>
<summary>Windows</summary>

  **Enable script execution:**
  ```powershell
  Set-ExecutionPolicy Unrestricted -Scope CurrentUser
  ```

  <details open>
  <summary>Interactive</summary>

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
  <summary>With Parameters</summary>

  **Add data:**
  ```powershell
  $code = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Jair-F/small_scripts/refs/heads/master/transfer/add_data.ps1").Content; Invoke-Expression $code -InputFile "myfile.pdf" -NumOfKBytes 8
  ```

  **Remove data:**
  ```powershell
  $code = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Jair-F/small_scripts/refs/heads/master/transfer/remove_data.ps1").Content; Invoke-Expression $code -InputFile "myfile.pdf.bin"
  ```

  </details>

</details>


## Linux Usage

<details open>
<summary>Linux</summary>

  <details open>
  <summary>Interactive</summary>

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
  <summary>With Parameters</summary>

  **Add data:**
  ```bash
  curl -sL https://raw.githubusercontent.com/Jair-F/small_scripts/refs/heads/master/transfer/add_data.sh | bash -s myfile.pdf 8
  ```

  **Remove data:**
  ```bash
  curl -sL https://raw.githubusercontent.com/Jair-F/small_scripts/refs/heads/master/transfer/remove_data.sh | bash -s myfile.pdf.bin
  ```

  </details>

</details>


**Notes:** Max 99 KB per operation (Linux). Output: `.bin` from add_data, original name from remove_data.
