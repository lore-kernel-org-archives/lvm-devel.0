From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 14 Oct 2010 12:24:26 +0100
Subject: [PATCH] lvconvert: provide useful error when snapshot-merge target missing
In-Reply-To: <4CB6C782.6020501@redhat.com>
References: <20101013185302.GA2944@redhat.com> <4CB6034D.5080603@redhat.com>
	<20101013214257.GC32395@agk-dp.fab.redhat.com>
	<4CB6C782.6020501@redhat.com>
Message-ID: <20101014112426.GD32395@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Oct 14, 2010 at 11:04:02AM +0200, Zdenek Kabelac wrote:
> I'd propose to drop/turn off this feature completely - targets usually cannot
> work without heavy tweaking through the rest of the code anyway. So in fact we
> rather 'pretend' there is such functionality.

The reason for the shared libraries is so that a distro can ship support
for older formats like LVM1 or pool but people who know they don't need
it don't have to have it loaded it all the time.

There's no problem to fix here IMHO, but if there was, we'd simply
attach the full version (2.02.72) to the soname of those libraries to
enforce the requirement to recompile.
 
Alasdair


