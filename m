From: Milan Broz <mbroz@redhat.com>
Date: Sat, 26 Mar 2011 11:09:17 +0100
Subject: [PATCH 2/3] Set our own in/out buffers
In-Reply-To: <49609a18834f11b833c31a164a2b467dd52095f3.1301089240.git.zkabelac@redhat.com>
References: <cover.1301089240.git.zkabelac@redhat.com>
	<49609a18834f11b833c31a164a2b467dd52095f3.1301089240.git.zkabelac@redhat.com>
Message-ID: <4D8DBB4D.9060604@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 03/25/2011 10:57 PM, Zdenek Kabelac wrote:
> Memory lock from critical_section is now being kept over the critical
> section - mallopt() should ensure, that mmap is not used for allocation,
> and we preallocate some memory to be able to satisfy some small
> alloc request. However when glibc needs buffers for line buffering of
> input and output buffers - it allocates these buffers in such way it
> adds memory page for each such buffer and size of unlock memory check will
> mismatch by 1 or 2 pages.

ack in principle, these warnings appears quite often on various places
and distract people form real problems.

> +    	static char inbuf[4096];
> +	static char outbuf[4096];

Because we are handling stdin/stdout, I think this call is common
for glibc, right?

Shouldn't this be initialized only once (do we support multiple command
contexts, IOW reentrant code here)? Is create_toolcontext() the right
place for it?

Milan


