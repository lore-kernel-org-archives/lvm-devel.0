From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Jul 2009 09:44:20 -0400
Subject: [PATCH] Change all liblvm2app API calls to return void and note use of lvm_errno.
In-Reply-To: <1248234370-12773-1-git-send-email-dwysocha@redhat.com>
References: <1248234370-12773-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1248270260.2441.74.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, 2009-07-21 at 23:46 -0400, Dave Wysochanski wrote:
> Remove the return 'int' value for most of liblvm2app calls.  We now have
> lvm_errno and lvm_errmsg.  Update test/api/vgtest.c
> 

Withdrawing this patch for now.


