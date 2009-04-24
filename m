From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 24 Apr 2009 12:12:31 +0100
Subject: [PATCH] Fix segfault when using -U, -G and -M options in dmsetup
In-Reply-To: <49F1979E.7030108@redhat.com>
References: <49F1979E.7030108@redhat.com>
Message-ID: <20090424111231.GE15019@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Apr 24, 2009 at 12:42:38PM +0200, Peter Rajnoha wrote:
> We have to define ":" in getopt for options that require parameters.
 
Ack.

Alasdair
-- 
agk at redhat.com


