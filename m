From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 04 Nov 2012 13:28:52 +0100
Subject: [PATCH 0/3] lvm2app: Possible lvm_lv_resize impl (V2)
In-Reply-To: <1351888390-12619-1-git-send-email-tasleson@redhat.com>
References: <1351888390-12619-1-git-send-email-tasleson@redhat.com>
Message-ID: <50965F84.1010409@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 2.11.2012 21:33, Tony Asleson napsal(a):
> This patch set implements lvm_lv_resize for the lvm2app API.
>
> As this patch set is pretty large and touches a number of different areas
> I would appreciate folks to review.  Specifically the first patch where
> I added a flag to lv to do additional steps on a vg_commit.  In addition
> as users of the API are unable to interact the re-size has a implicit force, so
> users could potentially lose data if they reduce the size of the lv.
>
> Proposed changes pass local unit testing.
>
> V2 - Removed automatic whitespace cleanup so patches are easier to
>       read.

I think at this point the library is not ready for this change, and needs
some more decisions to be made before we start to make such steps.

I'd like to first see how the external API would look like at python 'user' level.

How do you want to make  python developer let use the lvm object?

Do you want to give him 'power of  vg_write/vg_commit' to his hands ?

So far design  allowed to control objects on VG level - which has many
aspects of consistency across cluster, it's basic unit of locking.

If we release the very strict and tight rules that are hard coded via
many hacks within liblvm internal (and admitelly many of them are not even 
docuemted) - we have to be sure what we lose and what we gain from such moves.

How do you want to control thing like  'lvcreate' args for python
user - since a lot of changes happens at this place (and lot will happen
when new targets are added).
I cannot really imagine any 'stable' API you might give python
user - unless you would simply allow to pass string parameter
like you give for lvcreate  cmdline now. Python needs to go via
complex  tools/lvcreate source file - there is currently no way to have the 
smartness of args parsing in lib/metadata subdir.

Here is just one of many examples which comes to my head -

While it might look ok to  create multiple linear LVs at once,
you would get into seriuos problem if you would want to create
thin pool and thin LVs at the same commit.

How do we plan to have consistent API changes in python and rest of lvm -
i.e. adding new supported target type usually (with current code stage)
leads to many changes across whole code base - including /tools subdir.
If the python binding binds to /lib and skips /tools interface,
we would have yet another place to keep in sync (and think of more
supported interfaces - i.e. ruby)

 From codding point -

I do not think it's good plan to move all the functionality from /tools
and /lib  for liblvm2api  -  why not rather link  libcmdlib  with API
if you want to make all the command externally available for python?

For now it seems like you want need to move all functions from  tools to 
lv_manip which is already pretty large source file. It's probably
better to keep functionality in separate files.

The current stage of lvm2 library is not really object oriented in terms,
you could manipulate with internal data structures easily - since there
is rather a lot of cached things connected together (and cache must stay
intact - there are even extra debug options to control and check its consistency)

So to see how to make things towards supporting non-lvmcmd user we need to 
consider many things together.

Is the python API designed to working only in 'anaconda' like environment,
(where you've not strict memory rules) or is it supposed to work anytime ?

Zdenek


