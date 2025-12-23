Received: from mail-lf1-f41.google.com (mail-lf1-f41.google.com [209.85.167.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4F9E71F8AC8
	for <lvm-devel@lists.linux.dev>; Tue, 23 Dec 2025 05:30:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1766467809; cv=none; b=Abp9Z5nmv9g7QmPKdqGQk0VvNAMPkef6GMvVztA4wqJ4o7+Lgn6rMwrGsis8Z7IukF0sujr0qxWWgOGfKn/vdN1p6cfXQQ3Vh1+rILGOwCJSuw9dlR1f76Ltcy1ZDZM8gZ+Mygle/estXR5yaR5BGAihp4B6R72nBfj3BcRmS3g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1766467809; c=relaxed/simple;
	bh=LeHgaTCg3sZgaNtwPEbjvh+7JlJOUXsNXjaOCgEgLN4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=jn6UzUXfUTOJevhywqV9OeZuF0eK4OEzQLNSElup9hlnlMhjGDzHf2tmMFK1I95NAQau/qJZik8U+Lca9jfQo9QK4gxz52xUgwt3l9ZSV9LVZmpctgVu4einNMv9MSFjX2/PJpOEd3xhVrY600FojGDBr0AMs3/jWOH5kgazp7w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=XCMiUbuG; arc=none smtp.client-ip=209.85.167.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XCMiUbuG"
Received: by mail-lf1-f41.google.com with SMTP id 2adb3069b0e04-5959d9a8eceso5334004e87.3
        for <lvm-devel@lists.linux.dev>; Mon, 22 Dec 2025 21:30:06 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1766467804; x=1767072604; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=CjrVs5qAijx5UEiplGDR4bSOktnBgAEK/U0XoVs0/GM=;
        b=XCMiUbuGoig+6ARL14x6zTOkC2vTVaIKR4of892zwJU3py5CQ89QSzezCw+Mlin9Kz
         k9exm0eiosfnwXwg7a2cTLB3Djsa3klvPmct/vi+U0ylKR5BiQGC95ZQNNy7MvnotSMX
         QeByiLCOo6dc1zYRJnZQJusObAQPbNtkU2ivB2FTQ5PSMGuvvmuBQpXHUxGaIzIt1tNE
         NXuyHDaacGTQiAFNoMJG7IshbJ//iusJonl7P7nR9boCI5W0v3wrSYCZzqlYJdmxnrRC
         WwXXYIXEC9ffAyE7pJaBXMsbZITJ2j32C2T87v+goexhpFsiMWth9uEirUg0JLsXqMFi
         w4ow==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1766467804; x=1767072604;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=CjrVs5qAijx5UEiplGDR4bSOktnBgAEK/U0XoVs0/GM=;
        b=agUbPNJVzxBNeMvQ6ZTG+6cKzgWyhFU8SGjSgusZGlRCCBUQCY0tPlmo+jJFuc0v7w
         5ZEnLFni5Vde2PaqiogN8w5MXM4Rh+WYGxMLnPS0Lu4ygQZNNpm4VgQ9x53YgGexj5aF
         TYOdz4GATmdhE28jCZfNYTfrtGsxx4qaVFWJrZ6YsiEfaw/DuRUsXubke+MSR0OZrXp0
         SMmYQo3ref5GPX7IuBwesMSs7kprg0fU75A3smFQPbmZ3oRw0GTboBEavioDB6D/Yoew
         E7PyakC5K3aT4aEz+CdLfUqno6dCh0O9cP23cWVtGGUAcg7mN1thtgfQIdqmZIwSzAMp
         xkKA==
X-Forwarded-Encrypted: i=1; AJvYcCWZITRZHrSLiLVpfGG5+vbV9LU3vQ2mu/qjB9XULtuSLe7Zuqxcx0Wnl4/M4OoF/PcgxJR3wK5eZq0=@lists.linux.dev
X-Gm-Message-State: AOJu0YzFM4fYBrFfResmMnZHGPHsDE1e7BfVqk+m4dB5W+8N6GTJOIyi
	dftzbFg098PwUc3Tb8QYKN4V561Ub396t7oH3IVSuqcfRAfwKWBSO5ac
X-Gm-Gg: AY/fxX47s52WxHpC9CBHD0Rir0THi8z9Cd38oGxsBvkgWGfpzO/tGQe2wvLwvuXYE2Y
	pHABCkb2t63CcVZjbQRLmxAoN1owoLBACPlkSeEIIP7IzM2BjKFGN/GkfAUc3Nj6zNEZBIyZCR7
	Z5kxhM3e29WzhMGvLcj5Dv8LD7fEU90zGR0+lJgm7/TLkAoHU+YCieQVZJ6VxJbH3v6wGkwgi2h
	APgCqYRp3HIAjboF9Q1HN66UI0ytPyFqo3tFoWFsRfRPVMJ5MRDBZhFE5UH9I7E4133Zc/JN8OL
	kNYmtABAC3xGqhZ1Px+9Vig7ANrFclrGZokFM2SImW8xapCXLwud8c1jbew7XWSObiH+GbaIRqT
	irqUHcNadywAa6LzzXSqgTVeiFQCARk5Pi+RhuB9wSItcHvxV4mCGZk4dRbiSJovk3iArftu41P
	/s4xO0kQ8q
X-Google-Smtp-Source: AGHT+IFBJ4czf5dy7NoHG6Z5fLR0sF8QwzLoI7Shb3fIF5XKnuFbQtFm8MSKsqZe2birAQ3bGk4BUg==
X-Received: by 2002:a05:6512:3a85:b0:598:8f90:eff5 with SMTP id 2adb3069b0e04-59a17df6969mr4474213e87.53.1766467803957;
        Mon, 22 Dec 2025 21:30:03 -0800 (PST)
Received: from localhost ([194.190.17.114])
        by smtp.gmail.com with UTF8SMTPSA id 2adb3069b0e04-59a18618ce8sm3818747e87.54.2025.12.22.21.30.01
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 22 Dec 2025 21:30:02 -0800 (PST)
From: Askar Safin <safinaskar@gmail.com>
To: gmazyland@gmail.com
Cc: Dell.Client.Kernel@dell.com,
	dm-devel@lists.linux.dev,
	linux-block@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-lvm@lists.linux.dev,
	linux-mm@kvack.org,
	linux-pm@vger.kernel.org,
	linux-raid@vger.kernel.org,
	lvm-devel@lists.linux.dev,
	mpatocka@redhat.com,
	pavel@ucw.cz,
	rafael@kernel.org
Subject: Re: [RFC PATCH 2/2] swsusp: make it possible to hibernate to device mapper devices
Date: Tue, 23 Dec 2025 08:29:52 +0300
Message-ID: <20251223052952.2623971-1-safinaskar@gmail.com>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <86300955-72e4-42d5-892d-f49bdf14441e@gmail.com>
References: <86300955-72e4-42d5-892d-f49bdf14441e@gmail.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Milan Broz <gmazyland@gmail.com>:
> Anyway, my understanding is that all device-mapper targets use mempools,
> which should ensure that they can process even under memory pressure.

I used journal mode so far, but, as well as I understand, direct mode is
okay for my use case.

Okay, I spent some time carefully reading dm-integrity source code.

I have read v6.12.48, because this is kernel I use.

And I conclude that dm-integrity code never allocate (not even from mempool)...
...in main code paths (as opposed to initialization code paths)...
...in direct ('D') mode...
...if I/O doesn't fail and checksums match.

(As I said in previous letter, mempools are bad, too, as well as I understand.)

I found exactly one place, where we seem to allocate in main code path:
https://elixir.bootlin.com/linux/v6.12.48/source/drivers/md/dm-integrity.c#L1789
(i. e. these two kmalloc's).

But I think this okay, because:
- we pass GFP_NOIO, so, as well as I understand, this should not lead to
recursion
- we pass __GFP_NORETRY, so, as well as I understand, we will not block in
this kmalloc for too much time
- we gracefully handle possible failure

Other strange place I found is this:
https://elixir.bootlin.com/linux/v6.12.48/source/drivers/md/dm-integrity.c#L1704 .

But I think this is okay, because:
- integrity_recheck is only ever called from here:
https://elixir.bootlin.com/linux/v6.12.48/source/drivers/md/dm-integrity.c#L1857
- that integrity_recheck call is only ever happens if dm_integrity_rw_tag failed
- as well as I understand, dm_integrity_rw_tag can only fail if we got actual
I/O error or checksum mismatch

So, this mempool_alloc call is okay for my use case.

So: in 'D' mode everything should be okay for my use case.

Another note: I used very stupid way to search functions, which allocate:
if function has "alloc" in its name, then I consider it allocating. :)

And final note: there is an elephant in a room: bufio.

As well as I understand, when pages are swapped in my use case, they first
will get to dm-integrity bufio cache, and only after that, they will
actually hit disk.

This, of course, defeats whole purpose of swap.

And possibly can lead to deadlocks.

Is there a way to disable bufio?

Or maybe bufio is used for checksums and metadata only?

-- 
Askar Safin
