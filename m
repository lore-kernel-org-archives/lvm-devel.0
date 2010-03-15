From: malahal@us.ibm.com <malahal@us.ibm.com>
Date: Mon, 15 Mar 2010 10:41:33 -0700
Subject: [PATCH] Remove the double open with same mode
In-Reply-To: <20100313041826.GB7267@agk-dp.fab.redhat.com>
References: <ee77738483f149622d19.1268439476@localhost>
	<20100313041826.GB7267@agk-dp.fab.redhat.com>
Message-ID: <20100315174133.GA3188@us.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon [agk at redhat.com] wrote:
> On Fri, Mar 12, 2010 at 04:17:56PM -0800, Malahal Naineni wrote:
> >  	if ((open("/dev/null", O_RDONLY) < 0) ||
> > -	    (open("/dev/null", O_WRONLY) < 0) ||
> >  	    (open("/dev/null", O_WRONLY) < 0))
> >  		exit(EXIT_DESC_OPEN_FAILURE);
> 
> stdin, stdout, stderr

Then how about this:

diff -r 8db1b9ee17a8 daemons/dmeventd/dmeventd.c
--- a/daemons/dmeventd/dmeventd.c	Fri Mar 12 16:15:25 2010 -0800
+++ b/daemons/dmeventd/dmeventd.c	Mon Mar 15 10:38:49 2010 -0700
@@ -1650,9 +1650,10 @@ static void _daemonize(void)
 	for (--fd; fd >= 0; fd--)
 		close(fd);
 
-	if ((open("/dev/null", O_RDONLY) < 0) ||
-	    (open("/dev/null", O_WRONLY) < 0) ||
-	    (open("/dev/null", O_WRONLY) < 0))
+	/* open stdin, stdout, stderr */
+	if ((open("/dev/null", O_RDONLY) != 0) ||
+	    (open("/dev/null", O_WRONLY) != 1) ||
+	    (open("/dev/null", O_WRONLY) != 2))
 		exit(EXIT_DESC_OPEN_FAILURE);


