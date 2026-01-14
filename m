Received: from mail-wr1-f46.google.com (mail-wr1-f46.google.com [209.85.221.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2128435FF5F
	for <lvm-devel@lists.linux.dev>; Wed, 14 Jan 2026 07:27:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.46
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1768375651; cv=none; b=rDnWBq51gUu90A9VqB3k8V8smzOSykWtfEsd02y+kDSpxFBJ6uQoqMKPGy97fq84YSxrOupGCIShIfpKuBrcMNHUIWD9J6I4JBWsUPes4TmqciLPSXtBeYiTd+3cUMgxr8WX9U7aSeM0t8YTl3cdi6ksDFqpeqDkeGS2RWIJCxo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1768375651; c=relaxed/simple;
	bh=DQUeirNpPP89aLFHeqsLAGeTASvH8cy8TfogQVOev1c=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ZZv+Oi0GBGLF4bdaDGf143B6OBc8Xx2olf8tODFA08H0DF8fVbOGVncVAkUJJ2HM7kNYmAs50i+kmyjIh7XS1i5AzC3Im+ChK1xWq0sEv+aNq+OMxlsP03oOQXo85j5pmStMeVOJnOKxVSexhOpM9j5kK7EFMIpp03iEAmlPMPk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=XVfcB7lL; arc=none smtp.client-ip=209.85.221.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XVfcB7lL"
Received: by mail-wr1-f46.google.com with SMTP id ffacd0b85a97d-431048c4068so315078f8f.1
        for <lvm-devel@lists.linux.dev>; Tue, 13 Jan 2026 23:27:27 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1768375643; x=1768980443; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=Iatfbkb039XtZtG7yO5eMvoMHygvxkVJOdhG6yXVCuE=;
        b=XVfcB7lL+v9es3grZKFiIHM/hEYcoVkk7ccaGaxtbBZ7xq2uH48+86YUN6oQ4XcXvG
         ngMlFV41Gps+1uTRmHsmpJzVkNCmi6zSxWn+TDVMAhc1QViKcBnsLG/PlidmdWIkOT4a
         AKPWWVRKuAV97ccOXcta7Re2/Ty8Ol4/LwfS+YMiOdfwsymKYL9n96rbluflkNY/tD8E
         xqTn4kREBuClJwK+l2KgDc2r5YGEpOXfWag5K0MeqLXCSlowH8TPSNpTbnt8KtgxMxLj
         nMHXlLodDgENskpIeX5lq4ILYfTCRYbz7a8T2u7wK8dY04+TsREaLB6eWi6lpzpeOvvt
         XY7Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1768375643; x=1768980443;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=Iatfbkb039XtZtG7yO5eMvoMHygvxkVJOdhG6yXVCuE=;
        b=QBsi+3fX0FRzdNsLquIAPeEBMwvtHYcx8bEWVbrwIWMowuMkltWordq0e/Iip2hPEz
         jvliuJStMcFMW85kjxeAk5iUtVpGIqRBvJbVGSiuVkd3l7oz4ZFdqpPT51dPToEjtGNB
         w7ZD7HwqT1U0PjALuw8EOdT0fgPuzMJZFbS3xblNh1oE9v/V31OBEkDSjwW3fP69CY0z
         l6XytgRULTHBfvJbk7rVps3i220p55V2Llgg3l+Gv2j6FRLRf7iP++/kIL5tGIsNthbu
         mYe5ZDjYL57XU16LeTxdFfMOEVSUKXiyJAWz2BAcFpIVRwl6qv1dUidOHvPQ4lrqePSN
         JeDg==
X-Forwarded-Encrypted: i=1; AJvYcCVjyFhMVjxcq/k0YVoNnARKlvtnBqMF+23ZL16WM9cSvC69Q3N+4hqEAnyQCxNAP9qcOaPCOKdJ6O4=@lists.linux.dev
X-Gm-Message-State: AOJu0YwRR72/cK5fORsAdIaOY8+x1eVYIte7BEXrTY0l9xgDEeJrSPVb
	t5v3LRF5ZESMW6XLAoiNd2WecsVg8NsFZ8n4PMGaUPqvYxFCSVkOOQGl
X-Gm-Gg: AY/fxX6bm+jwaUkDQUIyX8AitxhSBkOtYzRXxTczpy4B8GkrHB1ueK4Fj6JLsBtmXmj
	5+7a0WDH3rDFGZLuJuq6OETKkTbc/oiawPyibRk5015H9r2Peoby+jI960VEdZk3ZCRULxoA9l/
	Rabie1qJ4ss6BIriHSeKrP0Rq+1jtpcSvBhsFhVxop2TekMmxO4vjtlnU/Iw/6gSuOvXCW26pkN
	Ce+ejocqtgCjO4/cM9iN5/YzDE5bGhLKEAaXnNQN07EEjJw7r/+FGc8RqEhDvU/eH4AAuwOLuZb
	nlO4dJkttflG7OWAqi+njeASecN6iEn6rbnesrP4eOT19ONAbeCrnaui055j3tC5hkCcUo0ENhM
	Jc7/WyaS+xIje/a0ZxKvSr5XDBI4J9gWdV0XnyHnbhPXZP8sjJQAYgsdK0dAjvDVosRBVcSQCC/
	Rjqes0KV0=
X-Received: by 2002:a05:6000:402c:b0:431:66a:cbda with SMTP id ffacd0b85a97d-43423d4709emr6998700f8f.0.1768375642965;
        Tue, 13 Jan 2026 23:27:22 -0800 (PST)
Received: from localhost ([212.73.77.104])
        by smtp.gmail.com with UTF8SMTPSA id ffacd0b85a97d-432bd0dacd1sm47532193f8f.4.2026.01.13.23.27.20
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 13 Jan 2026 23:27:22 -0800 (PST)
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
	torvalds@linux-foundation.org
Subject: Re: [RFC PATCH 2/2] swsusp: make it possible to hibernate to device mapper devices
Date: Wed, 14 Jan 2026 10:27:05 +0300
Message-ID: <20260114072705.2798057-1-safinaskar@gmail.com>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <b32d0701-4399-9c5d-ecc8-071162df97a7@redhat.com>
References: <b32d0701-4399-9c5d-ecc8-071162df97a7@redhat.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Mikulas Patocka <mpatocka@redhat.com>:
> Askar Safin requires swap and hibernation on the dm-integrity device mapper
> target because he needs to protect his data.

Now I see that your approach is valid. (But some small changes are needed.)

[[ TL;DR: you approach is good. I kindly ask you to continue with this patch.
Needed changes are in section "Needed changes". ]]

Let me explain why I initially rejected your patch and why now I think it is good.


= Why I rejected =

In your patch "notify_swap_device" call located before "pm_restrict_gfp_mask".

But "pm_restrict_gfp_mask" is call, which forbids further swapping. I. e.
we still can swap till "pm_restrict_gfp_mask" call!

Thus "notify_swap_device" should be moved after "pm_restrict_gfp_mask" call.

But then I thought about more complex storage hierarchies. For example,
swap on top of some dm device on top of loop device on top of some filesystem
on top of some another dm device, etc.

If we have such hierarchy, then hibernating dm devices should be intertwined
with freezing of filesystems, which happens in "filesystems_freeze" call.

But "filesystems_freeze" call located before "pm_restrict_gfp_mask" call, so
here we got contradiction.

In other words, we should satisfy this 3 things at the same time:

- Hibernating of dm devices should happen inside "filesystems_freeze" call
intermixed with freezing of filesystems
- Hibernating of dm devices should happen after "pm_restrict_gfp_mask" call
- "pm_restrict_gfp_mask" is located after "filesystems_freeze" call in current
kernel

These 3 points obviously contradict to each other.

So in this point I gave up.

The only remaining solution (as I thought at that time) was to move
"filesystems_freeze" after "pm_restrict_gfp_mask" call (or to move
"pm_restrict_gfp_mask" before "filesystems_freeze").

But:
- Freezing of filesystem might require memory. It is bad idea to call
"filesystems_freeze" after we forbid to swap
- This would be pretty big change to the kernel. I'm not sure that my
small use case justifies such change

So in this point I totally gave up.


= Why now I think your patch is good =

But then I found this your email:
https://lore.kernel.org/all/3f3d871a-6a86-354f-f83d-a871793a4a47@redhat.com/ .

And now I see that complex hierarchies, such as described above, are not
supported anyway!

This fully ruins my argument above.

And this means that your patch in fact works!


= Needed changes =

Please, move "notify_swap_device" after "pm_restrict_gfp_mask".

Also: you introduced new operation to target_type: hibernate.
I'm not sure we need this operation, we already have presuspend
and postsuspend. In my personal hacky patch I simply added
"dm_bufio_client_reset" to the end of "dm_integrity_postsuspend",
and it worked. But I'm not sure about this point, i. e. if
you think that we need "hibernate", then go with it.


-- 
Askar Safin
