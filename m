From: Milan Broz <mbroz@redhat.com>
Date: Wed, 29 Sep 2010 12:12:38 +0200
Subject: [PATCH 1/1] Maps fix
In-Reply-To: <867a4bada2ee53fcf310d54788e3b08868d5031e.1285601408.git.zkabelac@redhat.com>
References: <cover.1285601408.git.zkabelac@redhat.com>
	<867a4bada2ee53fcf310d54788e3b08868d5031e.1285601408.git.zkabelac@redhat.com>
Message-ID: <4CA31116.8050301@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 09/27/2010 05:31 PM, Zdenek Kabelac wrote:
> Read complete content of /proc/self/maps into one buffer without
> realocation in the middle of reading and before doing any m/unlock
> operation with these lines - as some of them gets change.
> With previous implementation we've read some mappings twice ([stack])

ACK, if it solves the problem with lock != unlock size error....

> +		for (len = 0 ; len < _maps_len; len += n) {
> +			if (!(n = read(_maps_fd, _maps_buffer + len, _maps_len - len))) {
> +				_maps_buffer[len] = '0';

typo '\0' :)

for the parsing simple lines it is quite complicated code but if we cannot get
file size from /proc in advance...

Milan


