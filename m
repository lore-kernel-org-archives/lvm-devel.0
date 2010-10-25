From: Milan Broz <mbroz@redhat.com>
Date: Mon, 25 Oct 2010 13:23:32 +0200
Subject: [PATCH 16/30] Fix void* pointer arithmetic
In-Reply-To: <b27d551f464cef87fdbf52580c9b74607e500793.1287994530.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
	<b27d551f464cef87fdbf52580c9b74607e500793.1287994530.git.zkabelac@redhat.com>
Message-ID: <4CC568B4.4020002@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 10/25/2010 10:24 AM, Zdenek Kabelac wrote:

>  static void _touch_memory(void *mem, size_t size)
>  {
>  	size_t pagesize = lvm_getpagesize();
> -	void *pos = mem;
> -	void *end = mem + size - sizeof(long);
> +	char *pos = mem;
> +	char *end = pos + size - sizeof(long);

And what about trash this "touch memory" code completely?

The whole idea of touching memory before locking is IMHO obsolete.

Locking memory should do this implicitly - can we prove that this
code has some effect on recent systems?

Milan


