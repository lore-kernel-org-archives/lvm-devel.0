From: Mikulas Patocka <mpatocka@redhat.com>
Date: Tue, 14 Jul 2009 17:40:56 -0400 (EDT)
Subject: Re: [PATCHES] dmeventd and dynamic library segtypes
In-Reply-To: <Pine.LNX.4.64.0907141652130.8166@hs20-bc2-1.build.redhat.com>
References: <Pine.LNX.4.64.0907141652130.8166@hs20-bc2-1.build.redhat.com>
Message-ID: <Pine.LNX.4.64.0907141736200.16256@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



On Tue, 14 Jul 2009, Mikulas Patocka wrote:

> Hi
> 
> Here are two patches to make dmeventd work with library segtypes.
> 
> The first one makes dmeventd debuggable (it always attempted to kill the 
> parent process, even if it didn't work), the second one fixes exported 
> symbols.
> 
> I also attach a stacktrace where it tried to load the segtypes, as 
> Alasdair wanted.
> 
> Mikulas

... an explanation what's happening there:

dmeventd loads libdevmapper-event-lvm2mirror.so.2.02 with dlopen without 
RTLD_GLOBAL (so that its symbols are available only explicitly with 
dlsym).

libdevmapper-event-lvm2mirror.so.2.02 loads liblvm2cmd.so.2.02 as a 
dependency

liblvm2cmd.so.2.02 scans the config file and loads segment type libraries

one of the segment libraries is liblvm2snapshot.so.2.02. It needs symbols 
find_config_tree_str and print_log. It can't find them because

a) the symbols are in liblvm2cmd.so.2.02, but they are not exported.
and
b) libdevmapper-event-lvm2mirror.so.2.02 was loaded without RTLD_GLOBAL, 
so even exported symbols are not available.

The patch fixes both these things.

Mikulas


