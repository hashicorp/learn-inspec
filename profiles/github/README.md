# Github Action Profile

This profile checks all markdown in the path (with glob).

## Example Workflow

```
 name: HashiCorp Syntax Checker
 on:
   push:
     paths:
     - "pages/**/*.mdx"
 jobs:
   inspec:
     name: Check Codeblocks
     runs-on: ubuntu-latest
     services:
       inspec-target:
         image: acidprime/inspec-target
         options: --name inspec-target
     steps:
       - name: Download Markdown
         uses: actions/checkout@v2.0.0
       - name: Run Syntax Checks
         uses: hashicorp/learn-inspec@master
         with:
           profile: 'github'
           markdown: ${{github.workspace}}
           github_token: ${{ secrets.GITHUB_TOKEN }}
       - name: Upload Test Results
         uses: actions/upload-artifact@v1
         if: always()
         with:
           name: Test Results HTML
           path: inspec.html
```

This workflow automatically tests all markdown with the path.
