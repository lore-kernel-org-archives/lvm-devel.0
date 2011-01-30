From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 30 Jan 2011 20:43:47 +0100
Subject: [PATCH 05/24] Perf: Fix multiple operations on the same node
In-Reply-To: <26382d082d66727c13809cb4216caec33468ad20.1296391340.git.zkabelac@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>
	<26382d082d66727c13809cb4216caec33468ad20.1296391340.git.zkabelac@redhat.com>
Message-ID: <4D45BF73.8080701@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 30.1.2011 13:57, Zdenek Kabelac napsal(a):
> With ability to stack many operations in one udev transaction -
> in same cases we are adding and removing same device at the same time.
> 
> This leads to a problem of checking stacked operations:
> i.e. remove /dev/node1 followed by create /dev/node1
> 


This patch a missing proper reaction when there is no locking at all.

Zdenek


