From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 8 Mar 2011 13:01:48 +0000
Subject: [PATCH] Fix clvmd return code for bad options.
In-Reply-To: <1299509154-30046-1-git-send-email-mbroz@redhat.com>
References: <1299509154-30046-1-git-send-email-mbroz@redhat.com>
Message-ID: <20110308130148.GA10767@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Mar 07, 2011 at 03:45:54PM +0100, Milan Broz wrote:
> We should return exit code 2 for unknown options.
> Patch also adds standart --help oprion instead
> of nonstandard (and getopt incomatible -?).
 
Ack.

Alasdair


