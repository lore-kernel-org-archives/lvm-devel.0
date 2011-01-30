From: Milan Broz <mbroz@redhat.com>
Date: Sun, 30 Jan 2011 21:35:04 +0100
Subject: [PATCH 12/24] Perf: Increase hash sizes
In-Reply-To: <2483686e0452fbdc01bccd983c0d85672fc400ee.1296391340.git.zkabelac@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>
	<2483686e0452fbdc01bccd983c0d85672fc400ee.1296391340.git.zkabelac@redhat.com>
Message-ID: <4D45CB78.8080208@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 01/30/2011 01:57 PM, Zdenek Kabelac wrote:
> Modify size of created hash tables in a way, it could be uniquely
> identified in debug code - as hash will be rouned up to nearest power

code obfuscation :) can we better add new has function or macro
which takes some identifier? (similar to pool create)

Why do you need such hacks?

> of two - so in most updated lines it presents no functional change.
> 
> There is one major increase of hass size for lv_hash from 128 to 1024 entries.
> (With ideal hash - in case of 10000 LVs - 10 LVs would ocuppy one slot -
> which should be still pretty fast).

Ack that part. Except that if I want 1024 I really do not want to push 999
there and believe it will be rounded :)

m.


