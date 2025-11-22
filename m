Received: from mail-lf1-f44.google.com (mail-lf1-f44.google.com [209.85.167.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C730948CFC
	for <lvm-devel@lists.linux.dev>; Sat, 22 Nov 2025 22:47:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.44
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1763851677; cv=none; b=BQXMq/ufydtrIJSCXomwj2AzCj6Oh/T7pam2rVNNQdTiMKNXH3OHwdRGKZt0SFNefk3hcZysbEa8WJjvYaiGKnF+D0Yw07/Kz5AlUdTYe9ug5GJzHq7PiMpAu1fGizuS3d6Pt2tJBCRGcHkJM39z9R9Nrm6IJ2S9E2D2truCFrE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1763851677; c=relaxed/simple;
	bh=mDmOqDRRV1GxRTkt03uYnfvm5YBI/u/mWZasnkUTwrI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=eqMx0ATyO9eAgm8yyaWYKa316lAasp9AImXBB5EGKXCeeSXxQf6MQd/UumainAb4Iu9UX76JRovqr0gqQVba13R4uIIw+3Hpi1Qx56uV44yywl+C0spky1Iaggv5yfjMP3t5pmFvqMa16qo6nz4qgTSrgsj0vkqH1KKrL2gyd4s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=TvWAfVpb; arc=none smtp.client-ip=209.85.167.44
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TvWAfVpb"
Received: by mail-lf1-f44.google.com with SMTP id 2adb3069b0e04-5957d7e0bf3so3899801e87.0
        for <lvm-devel@lists.linux.dev>; Sat, 22 Nov 2025 14:47:55 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1763851674; x=1764456474; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=mm9cJVhutkedd51ycbYwKmMqp19QwPFiX/ffFg8rVcg=;
        b=TvWAfVpbGetCW1LYJUdJ7UPtX+M9OB8xLXx9HsZh5CVUZ1O8fbM+4TVPxG00sXvcf2
         GTI6r8odIU/pgdn7sftlrF4Z8frboqXNWQ7VowyuEvnjeSZ8Et2S5vNi0lJrD5kYq0t1
         wm3LRPgzKrBKgLvHIOKonPH5mClFHK3+EOcOFsY43bSmYgOtgokQT+yu87fchu7NB5zI
         A+5GVCYwGS15szqIZZWSy24EJehlCkGN27vcBKJ/w/LcuAwR55OjQKMbPNjzOTyeLJA1
         nBgXWTtedWeNRAMP/BAEE5NAV/S7SSCe+CBs+sm/Yh3lWO8bhBnxcRRXYcfcf1WRgqQP
         utKQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1763851674; x=1764456474;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=mm9cJVhutkedd51ycbYwKmMqp19QwPFiX/ffFg8rVcg=;
        b=S2S0rhy5DjFCwnAetlUL0KizaSUFCrx6k0cO7UrEl2vme2n+OJQnD5O0oJNnc142XS
         m+eD4fW7223sJs3V3aEXIdHd+Fheg2CQBEnf2MaXU1q/PFfSubPHxzvMCRUniRA5H41+
         gOw7edcV7vQ3pM5jOwoQ+8YhNOrQhSOrU1ZELM19shhUBVmns0bimBaF7jktgLrGBpiK
         1FNTOyhszLPZoT2zDcePiKEp55mMu0TBdrL/P/4AAZMGKONDxkMPtFXGDO03/zvwltIb
         iP/WgSqmwo/LvpsDuOom1hwToGhk33HSfjB1jl1iggN37jGyBR+OhvBC+Tfel8KI6SiR
         ekEQ==
X-Forwarded-Encrypted: i=1; AJvYcCWqU3heihjuepUFxy2KjEF40sPkGTwrb1ZcqUbR9FUvUO68edhW8/74zq6Q6e60tIPrei5+AY2yYG4=@lists.linux.dev
X-Gm-Message-State: AOJu0YyTdw0S+icrqHiN2wMXTXL6UV9BB9paEMfdEnjQ0tgV1b+osurC
	7YIWYn90OrDYuB4MmwJKIuYW1CZR3iOqMYbApHZKkF8B1IPHOnbJYj3q
X-Gm-Gg: ASbGncsEpns8Wo6J3HgrtmrOQzrJDsle47qBPJtKc4zJZtwyU9WsBNeJ0T/ikh1OvPE
	KMzr2Sdu+5lAiMWu8J3P9V5phzJreFIGn+5JZkjEhNQocs2N3Tk7+O+NIsK4knWn+07BLdbVQOK
	+m1B1Hef9Lz548c8alnxxfaeyP+2W9u507llzssXBi6MKJ2JavcUegTtDYdCmin2olVuUJ9F8Ok
	H08rNpURZJ3IFzcLlfuUg2JbiC448LF+nvPa6rf9aHaK7U4fIGhYMo9FcBQ3UhAV7EwghmvlQg8
	p2ijTeXKVOllwY1HfUpKyn65ZQC3h3bQ6pRj161g6HMzJJqaCCoYi7yen88FDgN8RcidHmelq8Q
	YJOVNIMQDr3bINJUob+tgCVVYTR80DN/FVzpMYwzBEmSPpgihwePm6MD72H2LFz/faS7BtoEQ5z
	ilh1TIi9C9qw==
X-Google-Smtp-Source: AGHT+IG25dEQnHwaBToxpvBjTeZ/3RB3yCymIb0k9rzfOt31nS8ruDCrSu8IePguUMWt0EMXA9m5xw==
X-Received: by 2002:a05:6512:308c:b0:596:a000:596 with SMTP id 2adb3069b0e04-596a0000a2bmr3428587e87.10.1763851673743;
        Sat, 22 Nov 2025 14:47:53 -0800 (PST)
Received: from localhost ([109.167.240.218])
        by smtp.gmail.com with UTF8SMTPSA id 2adb3069b0e04-5969dbc5988sm2742367e87.78.2025.11.22.14.47.50
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 22 Nov 2025 14:47:52 -0800 (PST)
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
Date: Sun, 23 Nov 2025 01:47:48 +0300
Message-ID: <20251122224748.3724202-1-safinaskar@gmail.com>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <c44942f2-cf4d-04c2-908f-d16e2e60aae2@redhat.com>
References: <c44942f2-cf4d-04c2-908f-d16e2e60aae2@redhat.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Mikulas Patocka <mpatocka@redhat.com>:
> [PATCH 1/2] pm-hibernate: flush disk cache when suspending
> 
> There was reported failure that suspend doesn't work with dm-integrity.
> The reason for the failure is that the suspend code doesn't issue the
> FLUSH bio - the data still sits in the dm-integrity cache and they are
> lost when poweroff happens.

I tested this patchset (in Qemu). It works.

Here is script I used for testing:

https://zerobin.net/?66669be7d2404586#xWufhCq7zCoOk3LJcJCj7W4k3vYT3U4vhGutTN3p8m0=

Here are logs:

https://zerobin.net/?5d4a2abbad751890#WMcQl4FAZC9KqcAuJU3TSVr7wuVnPFwI7dlinA9QHOo=

Tested-By: Askar Safin <safinaskar@gmail.com>

There was no any reason to wait for me. You could easily test using script above.

Also: Linux shows this scary message when booting in Qemu:

[    0.512581] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA

So, FUA is not supported? Does it mean that this patch is wrong, and works purely
by chance?

-- 
Askar Safin
