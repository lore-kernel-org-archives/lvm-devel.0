From: Alasdair G Kergon <agk@redhat.com>
Date: Sat, 9 Jun 2012 13:28:11 +0100
Subject: [linux-lvm] LVM release 2.02.96 / git / veritysetup
In-Reply-To: <CAFJqGkPHjaCXPq4zYxHp_koMwxbku0w=1W0wNznM_nEnpGaUGg@mail.gmail.com>
References: <20120609002308.GD15806@agk-dp.fab.redhat.com>
	<4FD30CF2.8060505@redhat.com>
	<CAFJqGkPHjaCXPq4zYxHp_koMwxbku0w=1W0wNznM_nEnpGaUGg@mail.gmail.com>
Message-ID: <20120609122810.GG15806@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sat, Jun 09, 2012 at 06:00:42PM +0700, Somchai Smythe wrote:
> Do not package LVM release 2.02.96 at all, or just the verity stuff?
 
Just veritysetup - its interfaces/formats are still being changed
(within userspace - no interface changes are planned on the kernel side)
and the new version will not be backwards-compatible.

Alasdair


