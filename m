From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Sat, 05 Mar 2011 12:15:53 +0100
Subject: [PATCH 1/2] Fix read byte from char[-1] position
In-Reply-To: <20110304203946.GM10767@agk-dp.fab.redhat.com>
References: <cover.1299089143.git.zkabelac@redhat.com>	<4e9cb7c98861937ffc9ce6ac53b3e58124a2eb6f.1299089143.git.zkabelac@redhat.com>
	<20110304203946.GM10767@agk-dp.fab.redhat.com>
Message-ID: <4D721B69.1030208@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 4.3.2011 21:39, Alasdair G Kergon napsal(a):
> On Wed, Mar 02, 2011 at 07:09:07PM +0100, Zdenek Kabelac wrote:
>> When the ->params is empty string - access is made on the byte
>> before allocated buffer (catched by valgrind) - in case it would
>> constains 0x20 - it would even overwrite this buffer.
>> So fix by checking len > 0 before doing such access.
>> Optimise the code and use len counter instead of multiple strlen calls.
>  
> Needing more context for this one:
>   Under what conditions is the bug triggered?
>   What are the implications when it is?
> 

On my box this happend when 'error' target without params is activated for
fixing mirror
(t-activate-partial.sh   -  'lvchange -v --refresh --partial $vg/mirror')
Fixed table looks like this:

@PREFIX at vg-mirror_mimage_0: 0 8192 linear 253:13 0
mvg-lvol3: 0 256 linear 7:0 2816
mvg-mir_mimage_2: 0 2560 linear 7:0 8192
mvg-lvol2: 0 256 linear 7:0 2560
mvg-mir_mimage_1: 0 2560 linear 7:0 5632
mvg-lvol1: 0 256 linear 7:0 2304
@PREFIX at vg-mirror_mlog: 0 8192 linear 253:11 2048
mvg-mir_mimage_0: 0 2560 linear 7:0 3072
@PREFIX at vg-mirror: 0 8192 mirror disk 2 253:12 1024 2 253:14 0 253:15 0 1
handle_errors
mvg-lvol0: 0 256 linear 7:0 2048
@PREFIX at pv3: 0 68949 linear 7:1 137898
mvg-mir: 0 2560 mirror disk 2 253:4 512 3 253:5 0 253:6 0 253:7 0 1 handle_errors
@PREFIX at pv2: 0 68949 linear 7:1 68949
@PREFIX at pv1: 0 10000000 error
@PREFIX at vg-mirror_mimage_0-missing_0_0: 0 8192 error
mvg-mir_mlog: 0 256 linear 7:0 10752
@PREFIX at vg-mirror_mimage_1: 0 8192 linear 253:10 2048


On my little endian machine - this byte seems to be usually 0x00 - thus on
x86_64 it will just make a test for 0x20 and skip the loop - no write happens.

It's quite hard to guess what is actually stored before the allocated params
string starts - probably some internal malloc data - if I'd take is as 8byte
value - there is  0x21 in little endian form - which could mean that on big
endian machine  0x21 could be located on the checked address - so it's hard to
estimate whether there could be actually 0x20.

In case there would 0x20 - it would be overwritten with 0 - next loop check
would exit (0 != 0x20) - but the memory is already modified and it would
probably mean memory corruption (this is heavily dependent on how the malloc
is implemented).

So my guess is - on LE it's mostly harmless just access outside of allocated
memory, on BE it might eventually trigger some hard to estimate problems.

Zdenek


