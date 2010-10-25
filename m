From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 13:13:13 +0200
Subject: [PATCH 13/30] Eliminate uninitialized_var
In-Reply-To: <87k4l660f8.wl%ejt@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>	<0f16dc9e1e7859ac7a275bbd9218dda77bcabc7f.1287994530.git.zkabelac@redhat.com>
	<87k4l660f8.wl%ejt@redhat.com>
Message-ID: <4CC56649.3070804@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 25.10.2010 12:18, ejt at redhat.com napsal(a):
> At Mon, 25 Oct 2010 10:24:20 +0200,
> Zdenek Kabelac wrote:
>>
>> Use some default value instead of a random number for unknown
>> minor_version.
>>
>> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
> 
> Nack.  What if your default |sb_offset| is wrong?

Still better something defined - then completely random value.

But this patch is rather about make compiler analyzer quiet -
maybe  default: assert() for 'generic' version ?

>From the source code - we are actually using only  MD_MINOR_V0,
as is: minor = MD_MINOR_VERSION_MIN (== MD_MINOR_V0)

Zdenek


