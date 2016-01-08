From: Tony Asleson <tasleson@redhat.com>
Date: Fri,  8 Jan 2016 15:37:15 -0600
Subject: [PATCH 0/2] lvm shell enhancements
Message-ID: <1452289037-30597-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In an effort to avoid forking & exec'ing the lvm command line a user can create
a sub process and pipe commands to/from lvm utilizing lvm shell.  

However, this approach suffers from the following:
1. lvm shell uses GNU readline which echos STDIN to STDOUT and it also appends
   additional characters to STDOUT when doing this which complicates the code    
   communicating with lvm shell.
2. lvm shell ouputs messages to STDERR even when the command is successful, thus
   the client has no way to easily determine if the command completed
   successfully or not.

This patch series addresses these two issues, please review.

Thanks!

Tony Asleson (2):
  lvm.c: Don't use GNU readline when no tty
  lvm.c: Add return value lvm shell prompt

 tools/lvm.c |   71 +++++++++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 60 insertions(+), 11 deletions(-)


