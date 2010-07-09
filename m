From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 9 Jul 2010 14:20:18 +0100
Subject: [PATCH] pid files cleanup
In-Reply-To: <4C36E604.6090106@redhat.com>
References: <4C36E604.6090106@redhat.com>
Message-ID: <20100709132017.GZ22664@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jul 09, 2010 at 11:04:04AM +0200, Fabio M. Di Nitto wrote:
> - create_lockfile can probably use fcntl_lock_file, but I am not
> entirely sure about its behavior yet (specially the waiting note in the
> header), so I choose a safe path for now and use a known (to me)
> implementation.
 
Don't worry about that now if the code is moving to libdevmapper anyway.
Sharing it just brings in the existing code that can create the
directory path if it's not there, but it really always should be!

Alasdair


