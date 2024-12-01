program Demineur;
{
Auteur: Patrick Pr‚martin
Date: 06/09/1992.
Langage: Turbo Pascal 6.0
But: Jeu de r‚flexion, trouver des mines sur une grille en fonction du nombre
     de mines entourant une case.

     ParamŠtres:
       1er = Nb mines,
       2Šme = Nb Jokers,
       3Šme = CHEATCODE => \| non utilis‚es par les mines.
}
uses
    olf_software,
    u_code_clavier,
    u_score,
    u_parametre,
    u_mouse,
    u_m_util,
    crt,
    u_msg,
    u_curseur;

const
     num_ver = '1.0';
     dat_ver = '06/09/1992';
     xc = 30;
     yc = 6;
     cheat_code : boolean = false;

type
    t_tab = array [1..10, 1..10] of char;

var
   tab,
   ecr : t_tab;
   score,
   nb_mine,
   nb_mine_ok,
   nb_coup,
   nb_joker,
   nb_jok_use : integer;
   f2 : boolean;

function valid (x, y : byte) : boolean;
begin
  valid := (not cheat_code) or ((x <> y) and (x <> 10));
end; { valid }

function min (x, y : integer) : integer;
begin
  if (x < y)
  then
    min := x
  else
    min := y;
  {endif}
end; { min }

function max (x, y : integer) : integer;
begin
  if (x > y)
  then
    max := x
  else
    max := y;
  {endif}
end; { max }

function get_x (x : integer) : integer;
begin
  get_x := pred (xc+x*2);
end; { get_x }

function get_y (y : integer) : integer;
begin
  get_y := pred (yc+y);
end; { get_y }

procedure maj_score;
var
   max_score : integer;
begin
  score := score+nb_mine_ok+nb_mine+100-nb_jok_use-nb_joker;
  if (score < 0)
  then
    score := 0;
  {endif}
  max_score := 200+100+nb_mine-nb_joker;
  clrscr;
  nouveau_score (score, max_score);
  affichage_score;
  if (confirm (get_msg (1)))
  then
    sauve_score ('DEMIN');
  {endif}
end; { maj_score }

procedure gagne;
begin
  score := 200;
  alert (get_msg (3), al_wait);
  maj_score;
end; { gagne }

procedure perdu;
begin
  score := 0;
  alert (get_msg (4), al_wait);
  maj_score;
end; { perdu }

procedure initialisation;
var
   i,
   j : integer;
   ch : string;
begin
  cheat_code := cheat_code or param_del ('CHEATCODE');
  if (paramcount >= 1)
  then
    begin
      {$r-}
      val (paramstr (1), nb_mine, i);
      {$r+}
      if ((i <> 0) or (nb_mine < 25) or (nb_mine > 80))
      then
        nb_mine := 25;
      {endif}
    end
  else
    nb_mine := 25;
  {endif}
  if (paramcount >= 2)
  then
    begin
      {$r-}
      val (paramstr (2), nb_joker, i);
      {$r+}
      if ((i <> 0) or (nb_joker < 0) or (nb_joker > 25))
      then
        nb_joker := 25;
      {endif}
    end
  else
    nb_joker := 25;
  {endif}
  for i := 1 to 10 do
    for j := 1 to 10 do
      begin
        tab [i, j] := ' ';
        ecr [i, j] := ' ';
      end;
    {endfor}
  {endfor}
  for nb_mine_ok := 1 to nb_mine do
    repeat
      repeat
        i := succ (random (10));
        j := succ (random (10));
      until valid (i, j);
      if (tab [i, j] = ' ')
      then
        tab [i, j] := 'M'
      else
        tab [i, j] := 'm';
      {endif}
    until (tab [i, j] = 'M');
  {endfor}
  for i := 1 to 10 do
    for j := 1 to 10 do
      case (tab [i, j]) of
        'm' : tab [i, j] := 'M';
        ' ' :
          begin
            nb_coup := 0;
            for nb_mine_ok := max (1, i-1) to min (10, i+1) do
              for nb_jok_use := max (1, j-1) to min (10, j+1) do
                if (upcase (tab [nb_mine_ok, nb_jok_use]) = 'M')
                then
                  inc (nb_coup);
                {endif}
              {endfor}
            {endfor}
            tab [i, j] := chr (ord ('0')+nb_coup);
            if (tab [i,j] = '0')
            then
              ecr [i, j] := '0';
            {endif}
          end;
      end;
    {endfor}
  {endfor}
  nb_mine_ok := 0;
  nb_coup := 0;
  nb_jok_use := 0;
  score := 0;
end; { initialisation }

procedure dessin_ecran;
var
   i,
   j : byte;
begin
  textcolor (lightgray);
  textbackground (black);
  clrscr;
  textattr := (255-textattr) and 127;
  gotoxy (1, 1);
  write ('D‚mineur (v'+num_ver+'), (c) Patrick Pr‚martin/Olf Software '+dat_ver);
  clreol;
  gotoxy (1, 24);
  write (get_msg (5));
  gotoxy (11, 24);
  write (get_msg (6));
  gotoxy (21, 24);
  write (get_msg (7));
  gotoxy (31, 24);
  write (get_msg (8));
  gotoxy (41, 24);
  write (get_msg (12));
  textattr := (255-textattr) and 127;
  textcolor (red);
  for i := get_x (-1) to get_x (12) do
    begin
      gotoxy (i, get_y (-1));
      write (#176);
      gotoxy (i, get_y (12));
      write (#176);
    end;
  {endfor}
  for j := get_y (-1) to get_y (12) do
    begin
      gotoxy (get_x (-1), j);
      write (#176);
      gotoxy (get_x (12), j);
      write (#176);
    end;
  {endfor}
  textcolor (darkgray);
  textbackground (black);
  for i := 1 to 10 do
    for j := 1 to 10 do
      begin
        gotoxy (get_x (i), get_y (j));
        if (ecr [i, j] = ' ')
        then
          write ('_')
        else
          write (ecr [i, j]);
        {endif}
      end;
    {endfor}
  {endfor}
end; { dessin_ecran }

procedure gagne_perdu (c : char; x, y : integer);
var
   i, j : byte;
begin
  for i := 1 to 10 do
    for j := 1 to 10 do
      if ((tab [i, j] = 'M') or (ecr [i, j] = 'M'))
      then
        begin
          gotoxy (get_x (i), get_y (j));
          write (tab [i, j]);
        end;
      {endif}
    {endfor}
  {endfor}
  if ((c = 'X') and (tab [x, y] = 'M'))
  then
    perdu
  else
    begin
      nb_mine_ok := 0;
      for x := 1 to 10 do
        for y := 1 to 10 do
          if ((ecr [x, y] = 'M') and (tab [x, y] = 'M'))
          then
            inc (nb_mine_ok);
          {endif}
        {endfor}
      {endfor}
      if (nb_mine_ok = nb_mine)
      then
        gagne
      else
        perdu;
      {endif}
    end;
  {endif}
end; { gagne_perdu }

function tout_plein : boolean;
var
   i, j : byte;
   res : boolean;
begin
  res := true;
  i := 1;
  while (i < 11) and res do
    begin
      j := 1;
      while (j < 11) and res do
        begin
          res := (ecr [i, j] <> ' ');
          inc (j);
        end;
      {endwhile}
      inc (i);
    end;
  {endwhile}
  tout_plein := res;
end; { tout_plein }

procedure aff_score;
begin
  gotoxy (1, 5);
  write (get_msg (10), ': ', nb_jok_use, '/', nb_joker);
  gotoxy (1, 7);
  write (get_msg (11), ': ', nb_mine_ok, '/', nb_mine);
end; { aff_score }

procedure traitement;
var
   fin : boolean;
   c : char;
   mx,
   my,
   mk : integer;
   x,
   y : byte;
begin
  initialisation;
  dessin_ecran;
  x := 1;
  y := 1;
  aff_score;
  gotoxy (get_x (x), get_y (y));
  curseur_pave;
  show_mouse;
  fin := false;
  repeat
    gotoxy (get_x (x), get_y (y));
    mk := 0;
    c := ' ';
    mouse_x_y_k_txt (mx, my, mk);
    if (keypressed)
    then
      c := readkey;
    {endif}
    if (mk > 0)
    then
      begin
        mx := max (0, 1+mx-xc) shr 1;
        my := max (0, 1+my-yc);
        if ((mx > 0) and (mx < 11) and (my > 0) and (my < 11))
        then
          begin
            x := mx;
            y := my;
            case (mk) of
              1 : c := 'X';
              2 : c := 'M';
            else
              c := '?';
            end;
          end
        else
          c := ' ';
        {endif}
      end;
    {endif}
    c := upcase (c);
    case c of
      touche_escape :  fin := confirm (get_msg (9));
      'X' :
        begin
          if (ecr [x, y] = 'M')
          then
            dec (nb_mine_ok);
          {endif}
          ecr [x, y] := tab [x, y];
          inc (nb_coup);
          gotoxy (get_x (x), get_y (y));
          hide_mouse;
          write (ecr [x, y]);
          aff_score;
          show_mouse;
        end;
      '?' :
        if ((nb_jok_use < nb_joker) and (ecr [x, y] = ' '))
        then
          begin
            inc (nb_jok_use);
            inc (nb_coup);
            if (tab [x, y] = 'M')
            then
              inc (nb_mine_ok);
            {endif}
            ecr [x, y] := tab [x, y];
            gotoxy (get_x (x), get_y (y));
            hide_mouse;
            write (ecr [x, y]);
            aff_score;
            show_mouse;
          end;
        {endif}
      'M' :
        begin
          inc (nb_mine_ok);
          inc (nb_coup);
          ecr [x, y] := 'M';
          gotoxy (get_x (x), get_y (y));
          hide_mouse;
          write (ecr [x, y]);
          aff_score;
          show_mouse;
        end;
      carac_nul :
        case readkey of
          touche_haut : y := max (1, pred (y));
          touche_bas : y := min (10, succ (y));
          touche_gauche : x := max (1, pred (x));
          touche_droite : x := min (10, succ (x));
          touche_f2 :
            begin
              fin := true;
              f2 := true;
            end;
        end;
    end;
    if ((nb_mine_ok = nb_mine) or (tout_plein) or ((tab [x, y] = 'M') and (c = 'X')))
    then
      begin
        fin := true;
        gagne_perdu (c, x, y);
      end;
    {endif}
  until fin;
end; { traitement }

begin
  checkbreak := false;
  randomize;
  init_licence ('GAMEDEMI');
  init_olf_message (mess_freeware);
  init_olf_software ('D‚mineur '+num_ver, #155' Patrick Pr‚martin '+dat_ver);
  curseur_off;
  hide_mouse;
  init_score ('DEMIN');
  repeat
    repeat
      f2 := false;
      traitement;
    until not F2;
  until not confirm (get_msg (2));
  textcolor (lightgray);
  textbackground (black);
  clrscr;
  hide_mouse;
  curseur_on;
end.
