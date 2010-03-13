From: Malahal Naineni <malahal@us.ibm.com>
Date: Fri, 12 Mar 2010 16:17:56 -0800
Subject: [PATCH] Remove the double open with same mode
Message-ID: <ee77738483f149622d19.1268439476@localhost>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Malahal Naineni (malahal at us.ibm.com)

diff -r 8db1b9ee17a8 -r ee77738483f1 daemons/dmeventd/dmeventd.c
--- a/daemons/dmeventd/dmeventd.c	Fri Mar 12 16:15:25 2010 -0800
+++ b/daemons/dmeventd/dmeventd.c	Fri Mar 12 16:16:15 2010 -0800
@@ -1651,7 +1651,6 @@ static void _daemonize(void)
 		close(fd);
 
 	if ((open("/dev/null", O_RDONLY) < 0) ||
-	    (open("/dev/null", O_WRONLY) < 0) ||
 	    (open("/dev/null", O_WRONLY) < 0))
 		exit(EXIT_DESC_OPEN_FAILURE);
 


