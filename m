From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 26 Apr 2010 16:56:02 +0200
Subject: [PATCH 09/22] Replicator: add sorted vgs_list
In-Reply-To: <20100426143404.GR23791@agk-dp.fab.redhat.com>
References: <cover.1271085009.git.zkabelac@redhat.com>	<4ac472dac5d9b6fe6833e169e5ccddceab1fa014.1271085009.git.zkabelac@redhat.com>
	<20100426143404.GR23791@agk-dp.fab.redhat.com>
Message-ID: <4BD5A982.80602@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 26.4.2010 16:34, Alasdair G Kergon napsal(a):
> On Mon, Apr 12, 2010 at 05:21:37PM +0200, Zdenek Kabelac wrote:
>> Introduce struct vgs_list to store information about needed
>> volume group name, vgid, flags and the pointer to opened VG.
>  
> Why does this need a new structure?

We don't have any similar one - I would be aware of.

Using new structure here seems to simplify modification of routines to be able
to process some loops multiple times  - i.e. code changes are minimal to
extend it for work with remote VGs.


> How does this interact with internal caches?

There is no interaction  - VGs are opened in alphabetical order via standard
lvm mechanism - there are no peeks into internal caches.

Technically we could find names in caches - but we should also keep locks for
all VGs during activation so noone changes them.

> How does this interact with 'struct volume_group' itself?  (The fields are
> already part of it so why is a new struct needed?)

We keep list of needed VGs outside in command - once we open 'master' VG -
list is moved (spliced) to internal VG list - then it's filled with
potentially missing 'other VGs' - later - if there was found problem in
processing caused by missing VG - list is taken out of VG - and in
alphabetical order opened again. And this loop iterates until either all
missing VGs are satisfied or some VG couldn't be opened -> failing resource.
This is a bit tricky - but we do not need to put things to global structure
like cmd_context in this case.

Zdenek


