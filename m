From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 20 Aug 2010 01:22:24 +0100
Subject: patch2/4: lvm manpages
In-Reply-To: <1282262321.3337.95.camel@fermat.scientia.net>
References: <1282262321.3337.95.camel@fermat.scientia.net>
Message-ID: <20100820002223.GV11907@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Aug 20, 2010 at 01:58:41AM +0200, Christoph Anton Mitterer wrote:
> Also removed pvdata from the list of unimplemented commands, as this

pvdata was an LVM1-specific command for examining LVM1 metadata.
I doubt we'll ever implement an equivalent for LVM2 now.
(Instead, we've been making information about the metadata 
available in other commands where it seems appropriate.)

Alasdair


