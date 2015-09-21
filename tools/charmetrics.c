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

#define FONTSIZE 256 /* Yields an appropriate sized character for the 256x256 square */
#define BASELINE_NORMALISE 64

#define MAXCHARBYTES 24 /* Tesseract has this limit, IIRC */
#define MAXCHARS 16384  /* Chosen arbitrarily as "big enough" */
#define MINZERO(x) ((x) > 0 ? (x) : 0)

typedef struct {
	char c[MAXCHARBYTES];
	int min_bottom, max_bottom;
	int min_top, max_top;
	int min_width, max_width;
	int min_bearing, max_bearing;
	int min_advance, max_advance;
	int unset;
} CharMetrics;

int main(int argc, char *argv[]) {
	CharMetrics cm[MAXCHARS];
	CharMetrics *cur;
	char c[MAXCHARBYTES];
	unsigned int cmnum, i, n;
	FILE *f;
	int baseline;
	int bottom, top, width, bearing, advance;
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
	cmnum = 0;
	while(fgets(c, MAXCHARBYTES, f) != NULL) {
		c[strlen(c) - 1] = '\0'; /* remove newline */
		if(cmnum < MAXCHARS) {
			strncpy(cm[cmnum].c, c, MAXCHARBYTES);
			cm[cmnum].min_bottom = cm[cmnum].max_bottom = -1;
			cm[cmnum].min_top = cm[cmnum].max_top = -1;
			cm[cmnum].min_width = cm[cmnum].max_width = -1;
			cm[cmnum].min_bearing = cm[cmnum].max_bearing = -1;
			cm[cmnum].min_advance = cm[cmnum].max_advance = -1;
			cm[cmnum].unset = 1;
			cmnum++;
		}
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

			bottom = MINZERO(baseline - (rect.y + rect.height));
			top = MINZERO(256 - rect.y);
			width = rect.width;
			bearing = MINZERO(PANGO_LBEARING(rect));
			advance = MINZERO(PANGO_RBEARING(rect));

			if(cur->unset) {
				cur->min_bottom = cur->max_bottom = bottom;
				cur->min_top = cur->max_top = top;
				cur->min_width = cur->max_width = width;
				cur->min_bearing = cur->max_bearing = bearing;
				cur->min_advance = cur->max_advance = advance;
				cur->unset = 0;
			}

			if(cur->min_bottom > bottom) {
				cur->min_bottom = bottom;
			}
			if(cur->max_bottom < bottom) {
				cur->max_bottom = bottom;
			}
			if(cur->min_top > top) {
				cur->min_top = top;
			}
			if(cur->max_top < top) {
				cur->max_top = top;
			}
			if(cur->min_width > width) {
				cur->min_width = width;
			}
			if(cur->max_width < width) {
				cur->max_width = width;
			}
			if(cur->min_bearing > bearing) {
				cur->min_bearing = bearing;
			}
			if(cur->max_bearing < bearing) {
				cur->max_bearing = bearing;
			}
			if(cur->min_advance > advance) {
				cur->min_advance = advance;
			}
			if(cur->max_advance < advance) {
				cur->max_advance = advance;
			}
		}
	}

	g_object_unref(layout);
	cairo_destroy(cr);
	cairo_surface_destroy(surface);

	for(i = 0, cur = cm; i < cmnum; i++, cur++) {
		printf("%s %d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n",
			cur->c,
			cur->min_bottom, cur->max_bottom,
			cur->min_top, cur->max_top,
			cur->min_width, cur->max_width,
			cur->min_bearing, cur->max_bearing,
			cur->min_advance, cur->max_advance
		);
	}

	return 0;
}
