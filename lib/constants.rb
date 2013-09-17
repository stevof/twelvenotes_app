module TwelveNotes
  class Constants
  
  	class Notes
      FLAT_SYMBOL = 'b'
      SHARP_SYMBOL = '#'

  		A = 'A'
  		A_SH = 'A#'
  		B_FL = 'Bb'
  		B = 'B'
  		C = 'C'
  		C_SH = 'C#'
  		D_FL = 'Db'
  		D = 'D'
  		D_SH = 'D#'
  		E_FL = 'Eb'
  		E = 'E'
  		F = 'F'
  		F_SH = 'F#'
  		G_FL = 'Gb'
  		G = 'G'
  		G_SH = 'G#'
  		A_FL = 'Ab'

  		NOTES_WITH_SHARPS = [ A, A_SH, B, C, C_SH, D, D_SH, E, F, F_SH, G, G_SH ] 
      NOTES_WITH_FLATS = [ A, B_FL, B, C, D_FL, D, E_FL, E, F, G_FL, G, A_FL ] 

      ALL_NOTES = {
        :sharps => NOTES_WITH_SHARPS,
        :flats  => NOTES_WITH_FLATS
      }
  	end
  end
end
