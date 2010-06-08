From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 08 Jun 2010 15:11:20 +0200
Subject: [PATCH] Introduce immediate_dev_node flag for dm tree items to support immediate node creation on demand
In-Reply-To: <4C0E371F.5020507@redhat.com>
References: <4C0E371F.5020507@redhat.com>
Message-ID: <4C0E4178.4010300@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 06/08/2010 02:27 PM, Peter Rajnoha wrote:
> So let's use a flag (or "load_property") called "immediate_dev_node" for such a dm tree
> node which triggers immediate synchronisation with udev and node creation when needed.

Just one thing to add. For now, the flag is checked for in
dm_tree_preload_children only! It's debatable whether we need
something like that in dm_tree_{activate, deactivate}_children...

And if yes, do we need to differentiate among these situations?

Peter


