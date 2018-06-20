#!/bin/bash

# Telmail - Send Mail with Attachments via telnet to SMTP mailserver
# Usage: `./telmail.sh`
#   -- Cole Hocking

# The MIME Boundary. It can't appear anywhere else in the message.
# (RFC 2045)
# Keep in mind, this one is also acting as a sort of 'signature';
# Maybe you want to change it... maybe you dont ;)
MIME_BOUND="KkK170891tpbkKk__FV_KKKkkkjjwq"

# TODO - Authlogin execute
# TODO - the read -a option is putting words in the array instead of lines.

show_banner() {
    # A cool banner -- yes, this is absolutely pointless.
    # ... but I'm keeping it.
    cat ./lib/telmail_banner_train.txt
    echo -e "\nSend mail to anyone, as anyone; via telnet to an SMTP server."
    echo -e "You know you want to... ;)\n"
    echo -e "Need to find an SMTP server? Try running './findme25s.sh'\n"
    echo -e "Be safe; and have fun.\n"
    echo -e "----------------------------------------------------------\n"
}

get_info(){
    # Get the mail server
    echo "smtp mail server:"
    read -p '> ' SERVER

    # Get the recipient name/address
    echo "recipient email address:"
    read -p '> ' RECIPIENT

    # Get the sender name/address
    echo "sender email address:"
    read -p '> ' SENDER

    # Email subject line
    echo "subject:"
    read -p '> ' SUBJECT
}

from_line_mask(){
    echo "sender name:"
    read -p '> ' FROMNAME
}

explain() {
    echo "If you use 'John Smith' as a sender mask, that's what will show up"
    echo "in the header of email address applications like Outlook;" 
    echo -e "rather than 'jsmith@example.com' showing up as the sender.\n"
    echo -e "So, do you want to mask the address?\n"
}

text_from_file() { 
    echo "Enter filename whose contents will be the message body:"
    read -p '> ' TEXTFILE
    if [[ -f $TEXTFILE ]]; then
        readarray TEXTARR < $TEXTFILE
    else
        echo "That file does not appear to exist, did you include the path?"
        text_from_file
    fi    
}

text_from_stdin() {
    echo "Enter the $CT text of the email. Type the '#' char when done."
    read -d '#' -a TEXTARR

}

# Get the attachment
get_attachment() {
    echo "Enter the filename to attach:"
    read -p '> ' AFILE
    if [[ -f $AFILE ]]; then
        B64_FILE=$(cat $AFILE | base64)
        echo "What do you want to call the attachment?"
        read -p '> ' ATTACH_NAME
    else 
        echo "That file does not appear to exist, did you include the path?"
        get_attachment
    fi
}

# Execute with text only
exec_text_only(){
    echo "open $SERVER 25"
    sleep 2
    echo "EHLO"
    sleep 2
    echo "MAIL FROM: $SENDER"
    sleep 2
    echo "RCPT TO: $RECIPIENT"
    sleep 2
    echo "DATA"
    sleep 2
    echo "$FROMLINE"
    echo "To: <$RECIPIENT>"
    echo "Subject: $SUBJECT"
    echo "MIME-Version: 1.0"
    echo "Content-Type:multipart/mixed;boundary=\"$MIME_BOUND\""
    echo ""
    # optional preamble
    echo "--$MIME_BOUND"
    echo "Content-Type:text/$CT"
    echo ""
    for i in ${TEXTARR[@]}; do
        echo "$i"
    done
    echo ""
    echo "--$MIME_BOUND--"
    # optional epilogue
    # terminating the data section requires <CRLF>.<CRLF>
    echo "."
    sleep 2
}

# Execute with text and attachments
exec_text_attach(){
    echo "open $SERVER 25"
    sleep 2
    echo "EHLO"
    sleep 2
    echo "MAIL FROM: $SENDER"
    sleep 2
    echo "RCPT TO: $RECIPIENT"
    sleep 2
    echo "DATA"
    sleep 2
    echo "$FROMLINE"
    echo "To: <$RECIPIENT>"
    echo "Subject: $SUBJECT"
    echo "MIME-Version: 1.0"
    echo "Content-Type:multipart/mixed;boundary=\"$MIME_BOUND\""
    echo ""
    # optional preamble
    echo "--$MIME_BOUND"
    echo "Content-Type:text/$CT"
    echo ""
    for i in ${TEXTARR[@]}; do
        echo "$i"
    done 
    echo ""
    echo "--$MIME_BOUND"
    echo "Content-Type:application/octect-stream;name=\"$ATTACH_NAME\""
    echo "Content-Transfer-Encoding:base64"
    echo "Content-Disposition: attachment;filename=\"$ATTACH_NAME\""
    echo ""
    echo "$B64_FILE"
    echo ""
    echo "--$MIME_BOUND--"
    # optional epilogue
    # terminating the data section requires <CRLF>.<CRLF>
    echo "."
    sleep 2
}

# Execute with attachments only
exec_attach_only(){
    echo "open $SERVER 25"
    sleep 2
    echo "EHLO"
    sleep 2
    echo "MAIL FROM: $SENDER"
    sleep 2
    echo "RCPT TO: $RECIPIENT"
    sleep 2
    echo "DATA"
    sleep 2
    echo "$FROMLINE"
    echo "To: <$RECIPIENT>"
    echo "Subject: $SUBJECT"
    echo "MIME-Version: 1.0"
    echo "Content-Type:multipart/mixed;boundary=\"$MIME_BOUND\""
    echo ""
    # optional preamble
    echo "--$MIME_BOUND"
    echo "Content-Type:application/octect-stream;name=\"$ATTACH_NAME\""
    echo "Content-Transfer-Encoding:base64"
    echo "Content-Disposition:attachment;filename=\"$ATTACH_NAME\""
    echo ""
    echo "$B64_FILE"
    echo ""
    echo "--$MIME_BOUND--"
    # optional epilogue
    # terminating the data section requires <CRLF>.<CRLF>
    echo "."
    sleep 2
}

main() {
    show_banner
    echo -e "First, let's gather some info...\n"
    get_info

    # Yes/no prompt for sender name mask
    #--------------------------------------------------------------------------
    echo -e "\nDo you want to mask the sender address?"
    select smask in "yes" "no" "wat?"; do  
        case $smask in
            yes ) from_line_mask; FROMLINE="From: \"$FROMNAME\" <$SENDER>"; break;;
            no ) FROMLINE="From: <$SENDER>"; break;;
            wat? ) explain; continue;;
        esac
    done
    #--------------------------------------------------------------------------
    # Prompt for message body text; (plaintext section of MIME)
    echo -e "\nMessage body options:"
    ADDTXT=1 # Default 1, unless they choose option 4
    select txtbody in "Plaintext from file" "HTML from file" "Enter plaintext manually" "Enter HTML manually" "No body text"; do
        case $txtbody in
            "Plaintext from file" ) CT="plain"; text_from_file; break;;
            "HTML from file" ) CT="html"; text_from_file; break;;
            "Enter plaintext manually" ) CT="plain" text_from_stdin; break;;
            "Enter HTML manually" ) CT="html"; text_from_stdin; break;;
            "No body text" ) ADDTXT=0; break;;
        esac
    done
    #--------------------------------------------------------------------------
    echo -e "\n Add Attachment?"
    ATTCH=1
    select attchopt in "Yes" "No"; do
        case $attchopt in
        "Yes" ) get_attachment; break;;
        "No" ) ATTCH=0; break;;
        esac
    done
    #--------------------------------------------------------------------------
    echo -e "\nGot it. I'm going in! Damn the torpedoes!\n"
    if [[ $ADDTXT == 1 && $ATTCH == 0 ]]; then
        exec_text_only | telnet
    elif [[ $ADDTXT == 1 && $ATTCH == 1 ]]; then
        exec_text_attach | telnet
    elif [[ $ADDTXT == 0 && $ATTCH == 1 ]]; then
        exec_attach_only | telnet   
    else
        echo "I don't want to send mail with no body and no attachments."
        echo "Aborting." 
        exit 1
    fi
}
main
