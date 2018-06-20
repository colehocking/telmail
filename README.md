```text
  _____             _    __  __             _       _    
 |_   _|   ___     | |  |  \/  |  __ _     (_)     | |   
   | |    / -_)    | |  | |\/| | / _` |    | |     | |   
  _|_|_   \___|   _|_|_ |_|__|_| \__,_|   _|_|_   _|_|_  
_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""| 
"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-' 

```
#### Send email via telnet, through an open SMTP server. You know you want to.

Sends SMTP MIME-encoded messages with optional attachments via telnet    
All message attachments are sent as base64-encoded binaries
As long as the server validates the sender, you can send the messages as anyone the server validates ;). You can also mask the sender address.  

##### This tool is for educational purposes only. I am not liable for what you do.
See the included license  


## Requirements  

- Bash version 4+
- masscan (if you want to use the SMTP scanner) 


## Usage  

- (to scan a network for open SMTP ports) `./findme25s.sh`  
- `./telmail.sh` (follow the user prompts)  




