From: Liuhua Wang <lwang@suse.com>
Date: Wed, 17 Aug 2016 17:04:24 +0800
Subject: Question about destroy_toolcontext()
Message-ID: <20160817090424.GA15400@wlh-host.bej.suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Peter,

I read the source of lib/commands/toolcontext.c
and have a question about the following lines:

----------------------------
void destroy_toolcontext(struct cmd_context *cmd){

[snip]

  #ifndef VALGRIND_POOL
    if (cmd->linebuffer) {
        /* Reset stream buffering to defaults */
        if (is_valid_fd(STDIN_FILENO) &&
            ((flags = fcntl(STDIN_FILENO, F_GETFL)) > 0) &&
            (flags & O_ACCMODE) != O_WRONLY) {
            if (_reopen_stream(stdin, STDIN_FILENO, "r", "stdin", &new_stream)) {
                stdin = new_stream;
                setlinebuf(stdin);
            } else 
                cmd->linebuffer = NULL; /* Leave buffer in place (deliberate leak) */
        }    

        if (is_valid_fd(STDOUT_FILENO) &&
            ((flags = fcntl(STDOUT_FILENO, F_GETFL)) > 0) &&
            (flags & O_ACCMODE) != O_RDONLY) {
            if (_reopen_stream(stdout, STDOUT_FILENO, "w", "stdout", &new_stream)) {
                stdout = new_stream;
                setlinebuf(stdout);
            } else 
                cmd->linebuffer = NULL; /* Leave buffer in place (deliberate leak) */
        }    

        dm_free(cmd->linebuffer);
    }    
  #endif
-------------------------------
when cmd->linebuffer is NULL and then dm_free(cmd->linebuffer),
won't it make it segfault?

Thanks!
Liuhua 


