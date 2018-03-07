#include "juliaset.h"
#include <stdio.h>
#include <stdlib.h>
#include <allegro.h>


void abort_on_error(const char* message)
{
	if(screen !=NULL)
		set_gfx_mode(GFX_TEXT, 0, 0, 0, 0);

	allegro_message("%s.\nLast Allegro error '%s'\n",
					message, allegro_error);

	exit(-1);
}

int main()
{
	double zoom = 1.0; //zoom
	double re_c = 0.0; //realna czesc stalej c
	double im_c = 0.0; //urojona czesc stalej c
	double view_x = 0.0;//punkty do przesuwania obrazu
	double view_y = 0.0;

	if (allegro_init() != 0) //inicjacja biblioteki graficznej
	    return 1;

	install_keyboard();
	set_color_depth( 24 );//ustawienie formatu pixeli na 24 bity

	set_gfx_mode( GFX_AUTODETECT_WINDOWED, 600, 600, 10, 10 ); //ustawienie okna programu 1050x1050




	BITMAP* picture = create_bitmap_ex(24, 600, 600);//stworz bitmape o rozmiarze 1000x1000, z 8-bitowymi pikselami

	if(!picture)
		abort_on_error("Nie udalo sie stworzyc bitmapy");

	clear_to_color(picture, makecol(255, 0, 0));//ustaw poczatkowo bitmape na kolor czerwony
	juliaset(picture->line, picture->w, picture->h, re_c, im_c, zoom, view_x, view_y);
	blit(picture, screen, 0, 0, 0, 0, picture->w, picture->h);

	while(!key[KEY_ESC])
	{
		
		if(key[KEY_Z])
			{	
				im_c = im_c - 0.01;
			}

		else if(key[KEY_X])
			{	
				im_c = im_c + 0.01;
			}

		else if(key[KEY_C])
			{	
				re_c = re_c - 0.01;
			}

		else if(key[KEY_V])
			{	
				re_c = re_c + 0.01;
			}
		else if(key[KEY_LEFT])
			{	
				view_x = view_x - 0.1/zoom;
			}

		else if(key[KEY_RIGHT])
			{	
				view_x = view_x + 0.1/zoom;
			}

		else if(key[KEY_UP])
			{	
				view_y = view_y + 0.1/zoom;
			}

		else if(key[KEY_DOWN])
			{	
				view_y = view_y - 0.1/zoom;
			}
		else if(key[KEY_O])
			{
				zoom = zoom * 1.5;
			}
		else if(key[KEY_P])
			{
				zoom = zoom / 1.5;
			}
		printf("c = %f+%fi,\nzoom:%f (%f,%f)\n", re_c, im_c, zoom, view_x, view_y);
		clear_to_color(picture, makecol(255, 0, 0));
		juliaset(picture->line, picture->w, picture->h, re_c, im_c, zoom, view_x, view_y);
		blit(picture, screen, 0, 0, 0, 0, picture->w, picture->h);

		readkey();

	}

	destroy_bitmap(picture);
	allegro_exit();
	return 0;


}
