From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 11 Oct 2010 13:28:36 +0200
Subject: [PATCH 6/9] Fix problem with fscking of mounted filesystem
In-Reply-To: <20101007172557.GA22053@agk-dp.fab.redhat.com>
References: <cover.1286460218.git.zkabelac@redhat.com>	<d1625c45c8e5f047113bc2f2af784e11e5e81249.1286460218.git.zkabelac@redhat.com>
	<20101007172557.GA22053@agk-dp.fab.redhat.com>
Message-ID: <4CB2F4E4.2000109@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 7.10.2010 19:25, Alasdair G Kergon napsal(a):
> On Thu, Oct 07, 2010 at 04:06:36PM +0200, Zdenek Kabelac wrote:
>> Instead of calling mount without parameter to get actual mount table,
>> switch to use /proc/mounts directly. (Not really sure, maybe we want to
>> use /proc/self/mounts?)
>  
> /proc/mounts I'd think: If it's mounted anywhere on the system, we need to
> be aware, even if it's not visible to the current process.
> 

I've been reading this rhbz:

https://bugzilla.redhat.com/show_bug.cgi?id=491924

Which seems to be suggesting to switch to to use self version.
On the other hand  /proc/mounts is symbolic link to self/mounts anyway.

Zdenek


