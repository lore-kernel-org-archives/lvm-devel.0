From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 30 Jan 2011 21:54:11 +0100
Subject: [PATCH 12/24] Perf: Increase hash sizes
In-Reply-To: <4D45CB78.8080208@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>	<2483686e0452fbdc01bccd983c0d85672fc400ee.1296391340.git.zkabelac@redhat.com>
	<4D45CB78.8080208@redhat.com>
Message-ID: <4D45CFF3.6000108@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 30.1.2011 21:35, Milan Broz napsal(a):
> On 01/30/2011 01:57 PM, Zdenek Kabelac wrote:
>> Modify size of created hash tables in a way, it could be uniquely
>> identified in debug code - as hash will be rouned up to nearest power
> 
> code obfuscation :) can we better add new has function or macro
> which takes some identifier? (similar to pool create)
> 
> Why do you need such hacks?

Well I've been thinking about few solutions - for this - so take this
just as an initial 'startup' - whether we want to extend API
with some new function with string parameter for hash description - or as some
'debug - like' version, which is compiled only with some debug option enabled.

Meanwhile - this was rather very easy 'quick and see' - as we don't have
named hashes, like we have for pools.

This hash part needs some polishing.

Zdenek


