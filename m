From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 20 Aug 2010 18:08:31 +0100
Subject: LVM2/lib/report properties.c
In-Reply-To: <1282315555.5781.8.camel@localhost.localdomain>
References: <20100820130240.24771.qmail@sourceware.org>
	<4C6E87E9.9040109@redhat.com>
	<1282315555.5781.8.camel@localhost.localdomain>
Message-ID: <20100820170831.GH11907@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I think it would fit better under liblvm at the moment, but it really is
no big deal.

If in future tools call the library they'll already be including that code
then too.

columns.h can be added to include/.symlinks to facilitate this.

Alasdair


