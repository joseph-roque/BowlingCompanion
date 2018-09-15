package ca.josephroque.bowlingcompanion.common.fragments

import android.content.Context
import android.support.design.widget.BottomSheetDialogFragment
import android.support.v4.app.DialogFragment
import android.support.v4.app.Fragment
import ca.josephroque.bowlingcompanion.NavigationActivity

/**
 * Copyright (C) 2018 Joseph Roque
 *
 * BaseFragment for all fragments in the application.
 */
abstract class BaseFragment : Fragment() {

    companion object {
        @Suppress("unused")
        private const val TAG = "BaseFragment"

        fun newInstance(name: String): BaseFragment {
            try {
                val fragmentClass = Class.forName(name)
                return fragmentClass.newInstance() as BaseFragment
            } catch (ex: Exception) {
                throw RuntimeException("All fragments must be a subclass of BaseFragment")
            }
        }
    }

    protected var fragmentNavigation: FragmentNavigation? = null
    protected var fabProvider: FabProvider? = null

    protected val navigationActivity: NavigationActivity?
        get() = activity as? NavigationActivity

    // MARK: BaseFragment

    abstract fun updateToolbarTitle()

    // MARK: Lifecycle functions

    override fun onAttach(context: Context?) {
        super.onAttach(context)
        context as? FragmentNavigation ?: throw RuntimeException("Parent activity must implement FragmentNavigation")
        fragmentNavigation = context
        context as? FabProvider ?: throw RuntimeException("Parent activity must implement FabProvider")
        fabProvider = context
    }

    override fun onDetach() {
        super.onDetach()
        fragmentNavigation = null
        fabProvider = null
    }

    override fun onStart() {
        super.onStart()
        updateToolbarTitle()
    }

    // MARK: FragmentNavigation

    interface FragmentNavigation {

        val stackSize: Int

        fun pushFragment(fragment: BaseFragment)
        fun pushDialogFragment(fragment: BaseDialogFragment)
        fun showBottomSheet(fragment: BottomSheetDialogFragment, tag: String)
        fun popFragment(fragment: BaseFragment)
    }

    // MARK: FabProvider

    interface FabProvider {
        fun invalidateFab()
    }
}
