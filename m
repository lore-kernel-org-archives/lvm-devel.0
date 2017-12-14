From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 14 Dec 2017 11:39:31 +0100
Subject: [PATCH] test: lvmetad_dump always timed out when using nc
In-Reply-To: <02180207-fc63-f9c2-64b0-82224eef1a3e@suse.com>
References: <20171213111303.24775-1-zren@suse.com>
	<02180207-fc63-f9c2-64b0-82224eef1a3e@suse.com>
Message-ID: <4b234d1c-be10-beba-642f-32bb5dc01ff4@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 14.12.2017 v 11:27 Eric Ren napsal(a):
> Hi zkabelac,
> 
> Hmm strange, tested on fedora, it has not this issue.
> 
> ```
> 

Hi

Yep - in fact I've  been a bit puzzled by your patch since I could not think 
why that should be needed.

We will possibly need to put OpenSuse as a test machine  somewhere.


Can you provide full test trace where you get lock ?


'make check_local T=selectsometest  VERBOSE=1 LVM_TEST_AUX_TRACE=1  &>/tmp/log'


Regads

Zdenek


