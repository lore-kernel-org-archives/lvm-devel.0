From: Jim Meyering <jim@meyering.net>
Date: Fri, 27 Apr 2007 12:00:54 +0200
Subject: clvmd-cman.c: another unchecked malloc
In-Reply-To: <87lkgf2qkj.fsf@rho.meyering.net> (Jim Meyering's message of
	"Thu\, 26 Apr 2007 15\:49\:48 +0200")
References: <87lkgf2qkj.fsf@rho.meyering.net>
Message-ID: <874pn216i1.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jim Meyering <jim@meyering.net> wrote:

> There's an unchecked malloc in clvmd-cman.c's get_members function:
>
> 	if (node_updown == NULL) {
> 		node_updown =
> 			(int *) malloc(sizeof(int) *
> 				       max(num_nodes, max_updown_nodes));
> 		memset(node_updown, 0,
> 		       sizeof(int) * max(num_nodes, max_updown_nodes));
> 	}
>
> Here's a fix.
> At the same time, I've taken the liberty of factoring out
> the common sub-expression (buffer length) and eliminating
> the cast on malloc's return value.
>
> 	* daemons/clvmd/clvmd-cman.c (get_members): Don't dereference NULL
> 	upon failed malloc.
>
> Index: daemons/clvmd/clvmd-cman.c
> ===================================================================
> RCS file: /cvs/lvm2/LVM2/daemons/clvmd/clvmd-cman.c,v
> retrieving revision 1.17
> diff -u -p -r1.17 clvmd-cman.c
> --- daemons/clvmd/clvmd-cman.c	23 Apr 2007 14:55:28 -0000	1.17
> +++ daemons/clvmd/clvmd-cman.c	26 Apr 2007 13:46:02 -0000
> @@ -320,11 +320,10 @@ static void get_members()
>  	}
>
>  	if (node_updown == NULL) {
> -		node_updown =
> -			(int *) malloc(sizeof(int) *
> -				       max(num_nodes, max_updown_nodes));
> -		memset(node_updown, 0,
> -		       sizeof(int) * max(num_nodes, max_updown_nodes));
> +		size_t buf_len = sizeof(int) * max(num_nodes, max_updown_nodes));

Whoops.
Now that I've installed enough -devel packages to compile that file,
I see that there are too many parentheses above.
Here's a corrected patch:

Index: daemons/clvmd/clvmd-cman.c
===================================================================
RCS file: /cvs/lvm2/LVM2/daemons/clvmd/clvmd-cman.c,v
retrieving revision 1.17
diff -u -p -r1.17 clvmd-cman.c
--- daemons/clvmd/clvmd-cman.c	23 Apr 2007 14:55:28 -0000	1.17
+++ daemons/clvmd/clvmd-cman.c	27 Apr 2007 10:00:06 -0000
@@ -320,11 +320,10 @@ static void get_members()
 	}

 	if (node_updown == NULL) {
-		node_updown =
-			(int *) malloc(sizeof(int) *
-				       max(num_nodes, max_updown_nodes));
-		memset(node_updown, 0,
-		       sizeof(int) * max(num_nodes, max_updown_nodes));
+		size_t bufsiz = sizeof(int) * max(num_nodes, max_updown_nodes);
+		node_updown = malloc(bufsiz);
+		if (node_updown)
+			memset(node_updown, 0, bufsiz);
 	}
 }


