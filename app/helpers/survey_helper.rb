module SurveyHelper
  def citizenship_options
    citizenships = [%w[Argentina Argentina], %w[Australia Australia], %w[Austria Austria],
                    %w[Belarus Belarus], %w[Belgium Belgium], %w[Benin Benin], %w[Brazil Brazil],
                    %w[Canada Canada], %w[Chile Chile], %w[China China], %w[Colombia Colombia],
                    ['Costa Rica', 'Costa Rica'], %w[Croatia Croatia], %w[Cyprus Cyprus],
                    ['Czech Republic', 'Czech Republic'], %w[Denmark Denmark], %w[Egypt Egypt],
                    %w[Finland Finland], %w[France France], %w[Germany Germany], %w[Greece Greece],
                    %w[Guanajuato Guanajuato], ['Hong Kong', 'Hong Kong'], %w[Hungary Hungary],
                    %w[Iceland Iceland], %w[India India], %w[Indonesia Indonesia], %w[Iran Iran],
                    %w[Iraq Iraq], %w[Israel Israel], %w[Italy Italy], %w[Japan Japan],
                    %w[Luxembourg Luxembourg], %w[Macau Macau], %w[Malaysia Malaysia], %w[Mexico Mexico],
                    %w[Morocco Morocco], %w[Netherlands Netherlands], ['New Zealand', 'New Zealand'],
                    %w[Norway Norway], %w[Perú Perú], %w[Philippines Philippines], %w[Poland Poland],
                    %w[Portugal Portugal], %w[Romania Romania], %w[Russia Russia],
                    ['Saudi Arabia', 'Saudi Arabia'], ['Sierra Leone', 'Sierra Leo'], %w[Singapore Singapore],
                    %w[Slovakia Slovakia], %w[Slovenia Slovenia], ['South Korea', 'South Korea'],
                    %w[Spain Spain], %w[Sweden Sweden], %w[Switzerland Switzerland], %w[Taiwan Taiwan],
                    ['The Bahamas', 'The Bahamas'], %w[Turkey Turkey], %w[UAE UAE], %w[Ukraine Ukraine],
                    ['United Kingdom', 'United Kingdom'], %w[Uruguay Uruguay], %w[USA USA],
                    %w[Venezuela Venezuela], %w[Vienna Vienna], %w[Vietnam Vietnam],
                    %w[Other Other], ['Prefer not to answer', 'Prefer not to answer']]
    citizenships.map { |disp, _value| disp }
  end

  def ethnicity_options
    ethnicity = [%w[Arab Arab], %w[Black Black], %w[Chinese Chinese], %w[Filipino Filipino],
                 ['Indigenous (within North America)', 'Indigenous (within North America)'],
                 %w[Japanese Japanese], %w[Korean Korean], ['Latin American', 'Latin American'],
                 ['South Asian (e.g., Indian, Pakistani, Sri Lankan)',
                  'South Asian (e.g., Indian, Pakistani, Sri Lankan)'],
                 ['Southeast Asian (e.g., Vietnamese, Cambodian, Laotian, Thai)',
                  'Southeast Asian (e.g., Vietnamese, Cambodian, Laotian, Thai)'],
                 ['West Asian (e.g., Iranian, Afghan)', 'West Asian (e.g., Iranian, Afghan)'],
                 %w[White White], %w[Other Other],
                 ['Prefer not to answer [Please note: If you choose this response, none of your other
                  responses to this question will be considered in the data analysis.]', 'Prefer not to answer']]
    ethnicity.map { |disp, _value| disp }
  end

  def gender_options
    gender = [%w[Woman Woman], %w[Man Man], ['Gender fluid and/or non-binary person',
                                             'Gender fluid and/or non-binary person'], %w[Other Other],
              ['Prefer not to answer', 'Prefer not to answer']]
    gender.map { |disp, _value| disp }
  end

  def indigenous_person_options
    indigenous = [%w[Yes Yes], %w[No No], ['Prefer not to answer', 'Prefer not to answer']]
    indigenous.map { |disp, _value| disp }
  end

  def indigenous_person_yes_options
    indigenous_yes = [['First Nation', 'First Nation'], %w[Métis Métis], %w[Inuit Inuit],
                      ['Native American', 'Native American'],
                      ['Indigenous from outside of what is now known as Canada and the United States',
                       'Indigenous from outside of what is now known as Canada and the United States'],
                      ['Prefer not to answer', 'Prefer not to answer']]
    indigenous_yes.map { |disp, _value| disp }
  end
end
