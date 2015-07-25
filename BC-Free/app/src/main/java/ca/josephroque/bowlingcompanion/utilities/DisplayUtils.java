package ca.josephroque.bowlingcompanion.utilities;

import android.content.res.ColorStateList;
import android.content.res.Resources;
import android.os.Build;
import android.support.design.widget.FloatingActionButton;
import android.view.ViewGroup;

/**
 * Created by Joseph Roque on 2015-07-24. Constants and methods for changes made to the UI.
 */
public final class DisplayUtils
{

    /** To identify output from this class in the Logcat. */
    @SuppressWarnings("unused")
    private static final String TAG = "DisplayUtils";

    /**
     * Default private constructor.
     */
    private DisplayUtils()
    {
        // does nothing
    }


    /**
     * Sets the primary and ripple colors of a {@link
     * android.support.design.widget.FloatingActionButton}.
     *
     * @param fab floating action button to adjust
     * @param primaryColor primary color of action button
     * @param rippleColor color of action button on press
     */
    public static void setFloatingActionButtonColors(FloatingActionButton fab,
                                                     int primaryColor,
                                                     int rippleColor)
    {
        int[][] states = {
                {android.R.attr.state_enabled},
                {android.R.attr.state_pressed},
        };

        int[] colors = {
                primaryColor,
                rippleColor,
        };

        ColorStateList colorStateList = new ColorStateList(states, colors);
        fab.setBackgroundTintList(colorStateList);
    }

    /**
     * Applies a workaround to fix {@link android.support.design.widget.FloatingActionButton}
     * margins pre-lollipop.
     *
     * @param resources to get screen density
     * @param fab floating action button to fix
     */
    public static void fixFloatingActionButtonMargins(Resources resources, FloatingActionButton fab)
    {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP)
        {
            final int underLollipopMargin = 8;
            final float scale = resources.getDisplayMetrics().density;
            ViewGroup.MarginLayoutParams p =
                    (ViewGroup.MarginLayoutParams) fab.getLayoutParams();
            p.setMargins(0, 0, DataFormatter.getPixelsFromDP(scale, underLollipopMargin), 0);
            fab.setLayoutParams(p);
        }
    }
}
