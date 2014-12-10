From: Eric Wheeler <ewheeler@ewheeler.net>
Date: Tue, 9 Dec 2014 18:52:08 -0800 (PST)
Subject: [PATCH] dm thin: optimize away writing all zeroes to unprovisioned blocks
In-Reply-To: <54871847.6020009@kernel.dk>
References: <alpine.DEB.2.00.1409301121470.26721@ware.dreamhost.com>
	<alpine.DEB.2.02.1412032237010.12556@ware.dreamhost.com>
	<alpine.DEB.2.02.1412032318290.29609@ware.dreamhost.com>
	<20141204153358.GA19315@redhat.com> <5481EB1C.4000202@kernel.dk>
	<20141205183342.GA27397@redhat.com>
	<alpine.DEB.2.02.1412061437430.19773@ware.dreamhost.com>
	<5483B04D.5030606@kernel.dk>
	<alpine.DEB.2.02.1412062028500.15919@ware.dreamhost.com>
	<5485D86C.9040800@kernel.dk>
	<alpine.DEB.2.02.1412082258460.10718@ware.dreamhost.com>
	<548715D2.1000509@kernel.dk> <54871847.6020009@kernel.dk>
Message-ID: <alpine.DEB.2.02.1412091725240.10718@ware.dreamhost.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> > >                dm-thinp (MB/s)   loopback (MB/s)   loop faster by
> > >
> > > ==============+======================================================
> > > random jobs=4 | 18496.0          33522.0           1.68x
> > > zeros  jobs=4 |  8119.2           9767.2           1.20x
> > > ==============+======================================================
> > > random jobs=1 |  7330.5          12330.0           1.81x
> > > zeros  jobs=1 |  4965.2           6799.9           1.11x
> > 
> > This looks more reasonable in terms of throughput.
> > 
> > One major worry here is that checking every write is blowing your cache,
> > so you could have a major impact on performance in general. Even for
> > O_DIRECT writes, you are now accessing the memory. Have you looked into
> > doing non-temporal memory compares instead? I think that would be the
> > way to go.
> 
> So I found your patch in the thread. For each vector, use memcmp() instead and
> hope it does the right thing. You can compare with empty_zero_page. That
> should drastically cut down on the amount of hand rolled code you have in
> bio_is_zero_filled() at the moment.

I ran these against dm-thinp within provision_block() when checking
  memcmp(page_address(ZERO_PAGE()), data, bv.bv_len) != 0
and got these numbers that show memcmp() based testing is rather slow:
  zeroed jobs=1 1268.1 MB/s
  zeroed jobs=4 1445.6 MB/s

  random jobs=1  7554.1 MB/s
  random jobs=4 17677.0 MB/s


I updated the checking code to use __uint128_t, and performance got even 
better than with 64-bit integers (note that gcc is emulating 128bit).  
These are the numbers w/ __uint128_t:

  zeroed jobs=1  6424 MB/s
  zeroed jobs=4 10738 MB/s MB/s

  random jobs=1  7928 MB/s
  random jobs=4 19435 MB/s MB/s


Jens says to try non-temporal memory compares to deal with cache 
invalidation, but that sounds like arch-specific assembler unless I am 
mistaken.  Does GCC have something I can use to flag the buffer as not to 
be cached?  If not, I'm happy to poke some asm code into the check 
routine, but I'm a bit rusty there.  

Can someone suggest the inline asm that I would use to rep until a 
non-zero value appears?  Assume that we are 8 or 16-byte aligned, probably 
the bigger the word sized checks are the better, performance wise.

My latest version is attached, and includes moving bvec_kunmap_irq out of 
the for loops in hopes of getting gcc to unroll loops.

-Eric

---
 block/bio.c |   74 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 74 insertions(+), 0 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index 8c2e55e..262f190 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -511,6 +511,80 @@ void zero_fill_bio(struct bio *bio)
 }
 EXPORT_SYMBOL(zero_fill_bio);
 
+bool bio_is_zero_filled(struct bio *bio)
+{
+	unsigned i, count, left;
+	unsigned long flags;
+	struct bio_vec bv;
+	struct bvec_iter iter;
+	char *data = NULL, *p;
+	__uint128_t *parch;
+
+	bio_for_each_segment(bv, bio, iter) {
+		data = bvec_kmap_irq(&bv, &flags);
+		p = data;
+		left = bv.bv_len;
+
+		if (unlikely( data == NULL ))
+			continue;
+
+
+		/* check unaligned bytes at the beginning of p */
+		if (unlikely( ( (uintptr_t)p & (sizeof(__uint128_t)-1) ) != 0 )) {
+			count = sizeof(__uint128_t) - ( (uintptr_t)p & (sizeof(__uint128_t)-1) );
+			for (i = 0; i < count; i++) {
+				if (*p) 
+					break;
+				p++;
+			}
+			if (i < count)
+				goto out_false;
+			left -= count;
+		}
+
+		/* we should be word aligned now */
+		BUG_ON(unlikely( ((uintptr_t)p & (sizeof(__uint128_t)-1) ) != 0 ));
+
+		/* now check in word-sized chunks */
+		parch = (__uint128_t*)p;
+		count = left >> ilog2(sizeof(__uint128_t)); /* count = left / sizeof(__uint128_t) */;
+		for (i = 0; i < count; i++) {
+			if (*parch) 
+				break;
+			parch++;
+		}
+		if (i < count)
+			goto out_false;
+		left -= count << ilog2(sizeof(__uint128_t)); /* left -= count*sizeof(__uint128_t) */
+
+		/* check remaining unaligned values@the end */
+		p = (char*)parch;
+		if (unlikely(left > 0))
+		{
+			for (i = 0; i < left; i++) {
+				if (*p)
+					break;
+				p++; 
+			}
+			if (i < count)
+				goto out_false;
+			left = 0;
+		}
+
+		bvec_kunmap_irq(data, &flags);
+		BUG_ON(unlikely( left > 0 ));
+		BUG_ON(unlikely( data+bv.bv_len != p ));
+	}
+
+	return true;
+
+out_false:
+	if (data != NULL)
+		bvec_kunmap_irq(data, &flags);
+	return false;
+}
+EXPORT_SYMBOL(bio_is_zero_filled);
+
 /**
  * bio_put - release a reference to a bio
  * @bio:   bio to release reference to
-- 
1.7.1


