From: Tony Asleson <tasleson@redhat.com>
Date: Mon, 17 Dec 2012 08:51:37 -0600
Subject: master - python-lvm: Make second lv.snapshot() argument optional
In-Reply-To: <50CCECF7.8000809@redhat.com>
References: <20121214221108.E6D52137F@hosted02.fedoraproject.org>
	<50CCECF7.8000809@redhat.com>
Message-ID: <50CF3179.8090406@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 12/15/2012 03:34 PM, Zdenek Kabelac wrote:
 > 2) using same size of origin is not enough to cover
>    i.e. full rewrite of origin device - you need some
>    'extra' size to store snapshot's metadata (remapping blocks)

How does a user calculate the correct size?

I would like to see an option to pass on snapshot creation that can
safely create a snapshot where every block can get written.

Regards,
Tony


