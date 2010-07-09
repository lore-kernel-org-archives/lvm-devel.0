From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 9 Jul 2010 14:11:39 +0100
Subject: [PATCH] pid files cleanup
In-Reply-To: <4C36E604.6090106@redhat.com>
References: <4C36E604.6090106@redhat.com>
Message-ID: <20100709131139.GY22664@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jul 09, 2010 at 11:04:04AM +0200, Fabio M. Di Nitto wrote:
> - I had some issues to build dmeventd that I need to investigate
> locally. dmeventd also needs to be ported (if possible) to use the
> library implementation of create_lockfile().
 
dmeventd is part of dm not lvm so has no access to lvm_internal!

For dmeventd to use the code, you need to move it into libdevmapper.
The function then needs a dm_ prefix and goes into libdm-file.c

Alasdair




