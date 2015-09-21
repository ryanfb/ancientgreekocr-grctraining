/*
 * Copyright 2014 Nick White <nick.white@durham.ac.uk>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Build with something like this:
 * cc `pkg-config --cflags --libs pangocairo` charmetrics.c -o charmetrics
 */

#define usage "charmetrics - calculates some metrics useful for a unicharset file\n" \
              "usage: charmetrics chars.txt [fontnames]\n"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pango/pangocairo.h>

#define LENGTH(X) (sizeof X / sizeof X[0])
#define MINZERO(x) ((x) > 0 ? (x) : 0)

#define FONTSIZE 256 /* Yields an appropriate sized character for the 256x256 square */
#define BASELINE_NORMALISE 64
#define MAXCHARBYTES 24 /* Tesseract defines this limit */

enum { Bottom, Top, Width, Bearing, Advance, MetricsLast }; /* Metrics */

typedef struct {
	int min;
	int max;
} MinMax;

typedef struct {
	char c[MAXCHARBYTES];
	MinMax metrics[MetricsLast];
	int unset;
} CharMetrics;

int main(int argc, char *argv[]) {
	CharMetrics *cm = NULL;
	int cmnum = 0;
	CharMetrics *cur;
	char c[MAXCHARBYTES];
	int metrics[MetricsLast];
	int i, j, n;
	FILE *f;
	int baseline;
	PangoFontDescription *font_description;
	PangoRectangle rect;
	cairo_surface_t *surface;
	cairo_t *cr;
	PangoLayout *layout;

	if(argc < 3) {
		fputs(usage, stdout);
		return 1;
	}

	if((f = fopen(argv[1], "r")) == NULL) {
		fprintf(stderr, "Can't open char file: %s\n", argv[1]);
		return 1;
	}
	while(fgets(c, MAXCHARBYTES, f) != NULL) {
		c[strlen(c) - 1] = '\0'; /* remove newline */
		cm = realloc(cm, sizeof(*cm) * ++cmnum);
		cur = cm + cmnum - 1;
		strncpy(cur->c, c, MAXCHARBYTES);
		for(i = 0; i < LENGTH(cur->metrics); i++) {
			cur->metrics[i].min = -1;
			cur->metrics[i].max = -1;
		}
		cur->unset = 1;
	}
	fclose(f);

	surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 0, 0);
	cr = cairo_create(surface);
	layout = pango_cairo_create_layout(cr);

	for(n = 2; n < argc; n++) {
		font_description = pango_font_description_from_string(argv[n]);
		pango_font_description_set_absolute_size(font_description, FONTSIZE * PANGO_SCALE);

		pango_layout_set_font_description(layout, font_description);
		pango_font_description_free(font_description);

		baseline = (pango_layout_get_baseline(layout) / PANGO_SCALE) + BASELINE_NORMALISE;

		for(i = 0, cur = cm; i < cmnum; i++, cur++) {
			pango_layout_set_text(layout, cur->c, -1);
			pango_layout_get_pixel_extents(layout, &rect, NULL);

			metrics[Bottom] = MINZERO(baseline - (rect.y + rect.height));
			metrics[Top] = MINZERO(256 - rect.y);
			metrics[Width] = rect.width;
			metrics[Bearing] = MINZERO(PANGO_LBEARING(rect));
			metrics[Advance] = MINZERO(PANGO_RBEARING(rect));

			if(cur->unset) {
				for(j = 0; j < LENGTH(metrics); j++) {
					cur->metrics[j].min = cur->metrics[j].max = metrics[j];
				}
				cur->unset = 0;
			}

			for(j = 0; j < LENGTH(metrics); j++) {
				if(cur->metrics[j].min > metrics[j]) {
					cur->metrics[j].min = metrics[j];
				}
				if(cur->metrics[j].max < metrics[j]) {
					cur->metrics[j].max = metrics[j];
				}
			}
		}
	}

	g_object_unref(layout);
	cairo_destroy(cr);
	cairo_surface_destroy(surface);

	for(i = 0, cur = cm; i < cmnum; i++, cur++) {
		fputs(cur->c, stdout);
		fputc(' ', stdout);
		for(j = 0; j < LENGTH(cur->metrics); j++) {
			printf("%d,%d", cur->metrics[j].min, cur->metrics[j].max);
			if(j != LENGTH(cur->metrics) - 1) {
				fputc(',', stdout);
			}
		}
		fputc('\n', stdout);
	}

	return 0;
}
