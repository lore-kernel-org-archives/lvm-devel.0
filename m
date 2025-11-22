Received: from mail-lj1-f172.google.com (mail-lj1-f172.google.com [209.85.208.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A572C284689
	for <lvm-devel@lists.linux.dev>; Sat, 22 Nov 2025 20:33:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1763843640; cv=none; b=usoBtFWGFPsX71HPbkxX1tVdZi3Qcz1O/qX7l7vNj3Rjkeo8skGc6aQH2VKNQ1D7utVlV7ncR5KKKxYOSYFCVxpgcatr9Jgb1io7Q09KNcVsTIN2UMMDTaWU0MM0RODX1jrKkBeyLrLiqrxXvJrmeebKwnFgPJYMcE/SW5nPZBc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1763843640; c=relaxed/simple;
	bh=NHaFMiF6dxiCU0vMg8q5qTDPlG31ZZujzGUesGhT5hQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=hF0ZdIG7HFNodhNP8nKhcsrFiUqE2Mo5/b62x+ipjBc5xXvyaxVE2WdyVqmn8KRbj/CAO9VwXoCdSivIfuOIql1LookWwi4sUclVTgz4SUONohFB44Z653s8t36ebYOp9Lw2kGMuTqntKMzry9obTNuD3YoX5VA1UZRD6eE0FCs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=jekE1Xbj; arc=none smtp.client-ip=209.85.208.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jekE1Xbj"
Received: by mail-lj1-f172.google.com with SMTP id 38308e7fff4ca-37b9728a353so32507781fa.0
        for <lvm-devel@lists.linux.dev>; Sat, 22 Nov 2025 12:33:57 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1763843636; x=1764448436; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=dFn2EwqFqpnjkFoKzC+88UIKZbJzPZxsjNZNiF3KFj4=;
        b=jekE1XbjT/IRhlo8FeigXqapbeoE+eZuRnO9/FeFB9MaaPBPRAzDnpyudUv34gWYzN
         aQr1512yk6l64K+d1V+xDYvGBpf2pysLvorI1pOJI/YOwUnltJKip4HleADclo0QLLzX
         5npT/EHDfJLRTZ4heopJU419CXwMRGEOFsS/G1IAR57nCuBqhySt0yieW8kJ/4tsKrFq
         8OLBdyv0k+JVTX7zXIN90C/MtZzyWuaH4iQvU6o4eU6BkzOpQ8E8QCztK56YRG6CACrH
         Hv71eXyOcXLcCKRlooFFX9GDBO/ErtGEQge9vgItzLbxRgbClDubMoWT1ZdRaNCZGZs/
         NLJw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1763843636; x=1764448436;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=dFn2EwqFqpnjkFoKzC+88UIKZbJzPZxsjNZNiF3KFj4=;
        b=jp0xSK20oxF7sAfq6Qm+BRkRTlOZwjR0DMfeFJOknU6ItOixY6Ho0Jg+jPz83bHqhi
         ds0yFad0yw1kSJiCISh1aYKhP/8AC9hnKIM4/dJNW+rh6tWtA2hlZPGb1lb8NPJhp6qO
         m753NtVl/wN2bhvabzQ6zng2d8NwMJH7hnhdOw7x/9Hw8ek02FBTfOt/Tx09YlFAeshP
         iTVbdGczM8fAK/UGwigfHGMOYoOERcHFuSRPxoohrrsglmhR2Ulg0PceVQFU0zD/vy9R
         wlcygPYeVMU4MELOTFZkz3YDyse1FOgrjIB1yskz8lc03LWLSFyh1rXHhnyMeGdZFAkX
         2JqQ==
X-Forwarded-Encrypted: i=1; AJvYcCUezpf4Wv7LEPte1kFZQMI/2dq8YElTyXOdZDVlIMNN6gSWDaI4vO45Y4+rojVrUHfJVh0odj3BthU=@lists.linux.dev
X-Gm-Message-State: AOJu0YySQDdX6azYHmPZoJ79zLNCLTizUMK5zcV6zKvW/vFqw/VkFpVQ
	kJvKAHjmzoyE/tHpldBhDWqJOn/2ktyae/hKHJZiDdUZIkGA80Udwh74
X-Gm-Gg: ASbGncue/dFxuF+tmx3KKYozxFV6zcELnfiVt5vbRX8rriJEdyFoZipmp3CbVEAtJd9
	tBFmDMhuhSJ2GOQ1o8fAJs/ZKbecyVB7a8PJY/0gahmMiT1jdINil8QGelQRetzWX+KoSbSxPSP
	OXQWLE/REpnUe0GfPlnp4SLkdvGPCH//zUxLitFd8aqs6oiwxbNF0Qy3KBDxHx2cwb8JrJ/ZFAF
	vTfyYy6x8uQu1SUVKj7pnGl62HvGwD44LFKmymYG6IcHMKPyz2sQouoVfQgJCXZEeLO/exFJ+me
	tWDbxGqHIxhUfftlfw0HGCkox8MhWfkL+relOWf4Hksvl6vuslcQ4Gq4o/fK5xMCn9HRBrlfYtp
	lZlK004LX2YsXhSG/XQtW5SlCp1LEc1ySmNHQzg2JpvFmBYFYfJaq+BDTabomWY525/C0/SSQt6
	KL9Aoy6gFG
X-Google-Smtp-Source: AGHT+IFhSsUjwtf7XXEFFhGewe4/WzYwa1EvQXhZvrF755UE0d1dYIej0yvrkJ/oBfshVizcRSlPOQ==
X-Received: by 2002:a05:651c:4416:10b0:37b:aac1:282e with SMTP id 38308e7fff4ca-37cd9287c95mr16773881fa.28.1763843635543;
        Sat, 22 Nov 2025 12:33:55 -0800 (PST)
Received: from localhost ([109.167.240.218])
        by smtp.gmail.com with UTF8SMTPSA id 38308e7fff4ca-37cc6b597b2sm19299711fa.12.2025.11.22.12.33.54
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 22 Nov 2025 12:33:55 -0800 (PST)
From: Askar Safin <safinaskar@gmail.com>
To: mpatocka@redhat.com
Cc: Dell.Client.Kernel@dell.com,
	agk@redhat.com,
	brauner@kernel.org,
	dm-devel@lists.linux.dev,
	ebiggers@kernel.org,
	kix@kix.es,
	linux-block@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-lvm@lists.linux.dev,
	linux-mm@kvack.org,
	linux-pm@vger.kernel.org,
	linux-raid@vger.kernel.org,
	lvm-devel@lists.linux.dev,
	milan@mazyland.cz,
	msnitzer@redhat.com,
	mzxreary@0pointer.de,
	nphamcs@gmail.com,
	pavel@ucw.cz,
	rafael@kernel.org,
	ryncsn@gmail.com,
	safinaskar@gmail.com,
	torvalds@linux-foundation.org
Subject: Re: [PATCH 1/2] pm-hibernate: flush disk cache when suspending
Date: Sat, 22 Nov 2025 23:33:42 +0300
Message-ID: <20251122203347.3484839-1-safinaskar@gmail.com>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <c44942f2-cf4d-04c2-908f-d16e2e60aae2@redhat.com>
References: <c44942f2-cf4d-04c2-908f-d16e2e60aae2@redhat.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Mikulas Patocka <mpatocka@redhat.com>:
> [PATCH 1/2] pm-hibernate: flush disk cache when suspending
> 
> There was reported failure that suspend doesn't work with dm-integrity.
> The reason for the failure is that the suspend code doesn't issue the
> FLUSH bio - the data still sits in the dm-integrity cache and they are
> lost when poweroff happens.

Your patchset is impossible to apply using "b4 shazam".

Here is what I get when I try to apply it using "b4 shazam":


d-user@comp:/tmp$ git clone --depth=1 git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
Cloning into 'linux'...
remote: Enumerating objects: 96577, done.
remote: Counting objects: 100% (96577/96577), done.
remote: Compressing objects: 100% (93936/93936), done.
remote: Total 96577 (delta 7530), reused 20945 (delta 1607), pack-reused 0 (from 0)
Receiving objects: 100% (96577/96577), 267.21 MiB | 1.85 MiB/s, done.
Resolving deltas: 100% (7530/7530), done.
Updating files: 100% (91166/91166), done.
d-user@comp:/tmp$ cd linux
d-user@comp:/tmp/linux$ b4 shazam 'c44942f2-cf4d-04c2-908f-d16e2e60aae2@redhat.com'
Grabbing thread from lore.kernel.org/all/c44942f2-cf4d-04c2-908f-d16e2e60aae2@redhat.com/t.mbox.gz
Checking for newer revisions
Grabbing search results from lore.kernel.org
Analyzing 15 messages in the thread
WARNING: duplicate messages found at index 1
   Subject 1: pm-hibernate: flush block device cache when hibernating
   Subject 2: pm-hibernate: flush disk cache when suspending
  2 is not a reply... assume additional patch
WARNING: duplicate messages found at index 2
   Subject 1: swsusp: make it possible to hibernate to device mapper devices
   Subject 2: pm-hibernate: flush disk cache when suspending
  2 is not a reply... assume additional patch
Checking attestation on all messages, may take a moment...
---
  ✓ [PATCH] pm-hibernate: flush block device cache when hibernating
    ✓ Signed: DKIM/redhat.com
  ✓ [PATCH RFC 2/2] swsusp: make it possible to hibernate to device mapper devices
    ✓ Signed: DKIM/redhat.com
  ✓ [PATCH 1/2] pm-hibernate: flush disk cache when suspending
    ✓ Signed: DKIM/redhat.com
  ERROR: missing [4/3]!
---
Total patches: 3
---
WARNING: Thread incomplete!
Applying: pm-hibernate: flush block device cache when hibernating
Applying: swsusp: make it possible to hibernate to device mapper devices
Patch failed at 0002 swsusp: make it possible to hibernate to device mapper devices
error: patch failed: kernel/power/swap.c:1591
error: kernel/power/swap.c: patch does not apply
hint: Use 'git am --show-current-patch=diff' to see the failed patch
hint: When you have resolved this problem, run "git am --continue".
hint: If you prefer to skip this patch, run "git am --skip" instead.
hint: To restore the original branch and stop patching, run "git am --abort".
hint: Disable this message with "git config advice.mergeConflict false"


It seems you should send patches not as a reply.

But I will apply your patches anyway, no need to resubmit.

-- 
Askar Safin
